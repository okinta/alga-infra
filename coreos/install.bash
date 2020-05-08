#!/usr/bin/env bash

#
# Installs FCOS on a machine
#

function load_var {
    local name=$1
    local value
    value=$(grep "export $name" < /root/.bashrc | awk '{print $2}' | awk -F "=" '{print $2}')
    eval "$name=${value@Q}"
    eval "export $name"
}

load_var CLOUDFLARE_API_KEY
load_var CLOUDFLARE_EMAIL
load_var VULTR_API_KEY

# Who are we?
ID="$(curl -s http://169.254.169.254/v1.json | jq '.instanceid' | tr -d '"')"
export ID
echo "export ID=\"$ID\"" >> /root/.bashrc
TAG=$(vultr-cli server info "$ID" | grep Tag | awk '{print $2}')
logdna-agent -t "$TAG"
export TAG
echo "export TAG=\"$TAG\"" >> /root/.bashrc
echo "Tag: $TAG"

# Configure this machine's private network
external_ip="$(curl -s http://169.254.169.254/v1.json | jq '.interfaces[0].ipv4.address' | tr -d '"')"
private_ip="$(curl -s http://169.254.169.254/v1.json | jq '.interfaces[1].ipv4.address' | tr -d '"')"
echo "network:
  version: 2
  renderer: networkd
  ethernets:
    ens7:
      mtu: 1450
      dhcp4: no
      addresses: [$private_ip/16]" > /etc/netplan/10-ens7.yaml
netplan apply
echo "Finished configuring private network"

SSH_KEY="$(cat /root/.ssh/authorized_keys)"
export SSH_KEY
echo "export SSH_KEY=\"$SSH_KEY\"" >> /root/.bashrc

PRIVATE_IP="$(curl -s http://169.254.169.254/v1.json | jq '.interfaces[1].ipv4.address' | tr -d '"')"
export PRIVATE_IP
echo "export PRIVATE_IP=\"$PRIVATE_IP\"" >> /root/.bashrc

PRIVATE_SUBNET="$(sed "s/\.[^\.]*$//" <<< "$PRIVATE_IP").0"
export PRIVATE_SUBNET
echo "export PRIVATE_SUBNET=\"$PRIVATE_SUBNET\"" >> /root/.bashrc

# Get the base fcc config ready
wget -q -O coreos.fcc.template \
    https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/coreos.fcc
envsubst < coreos.fcc.template > coreos.fcc

# If we're not establishing the Vault, then load our private registry credentials
if [ "$TAG" != "stack-vault" ]; then

    # Pull registry credentials from the Vault
    echo "Loading container registry credentials from Vault"

    CONTAINER_REGISTRY=$(timeout 5s curl -s http://vault.in.okinta.ge:7020/api/kv/registry_name)
    export CONTAINER_REGISTRY
    echo "export CONTAINER_REGISTRY=\"$CONTAINER_REGISTRY\"" >> /root/.bashrc

    if [ -z "$CONTAINER_REGISTRY" ]; then
        echo "Could not connect to Vault"
        exit 1
    fi

    password=$(timeout 5s curl -s http://vault.in.okinta.ge:7020/api/kv/registry_password)
    user=$(timeout 5s curl -s http://vault.in.okinta.ge:7020/api/kv/registry_login)
    CONTAINER_REGISTRY_AUTH=$(echo -n "$user:$password" | base64)
    export CONTAINER_REGISTRY_AUTH
    echo "export CONTAINER_REGISTRY_AUTH=\"$CONTAINER_REGISTRY_AUTH\"" >> /root/.bashrc

    # Inject the registry credentials into the coreos configuration
    wget -q -O registry.fcc.template \
        https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/registry.fcc
    envsubst < registry.fcc.template > registry.fcc
    yq merge -i --append coreos.fcc registry.fcc
    rm registry.fcc
    echo "Injected container registry credentials into ignition config"
fi

if [[ "$TAG" == stack* ]]; then
    echo "Installing $TAG"

    # Update the DNS to point to this server
    stack=${TAG#stack-}
    if cf-update.sh \
        "$CLOUDFLARE_EMAIL" \
        "$CLOUDFLARE_API_KEY" \
        "okinta.ge" \
        "$stack.in" \
        "$private_ip"; then
        echo "Updated $stack.in.okinta.ge to point to $private_ip"
    fi

    wget -q "https://raw.githubusercontent.com/okinta/$TAG/master/coreos.fcc" -O stack.fcc
    yq merge --append coreos.fcc stack.fcc | fcct > coreos.ign
    coreos-installer install /dev/vda -i coreos.ign

    # Update public DNS
    if yq read stack.fcc "passwd.users[*].name" | grep -w public; then
        cf-update.sh \
            "$CLOUDFLARE_EMAIL" \
            "$CLOUDFLARE_API_KEY" \
            "okinta.ge" \
            "$stack" \
            "$external_ip"
        echo "Updated $stack.okinta.ge to point to $external_ip"
    fi

elif [ "$TAG" = "fcos" ]; then
    echo "Installing default fcos server with root access"

    wget -q -O root.fcc.template \
        https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/root.fcc
    envsubst < root.fcc.template > root.fcc

    # Give the first defined user sudo access
    yq write coreos.fcc "passwd.users[0].groups[+]" sudo | fcct > coreos.ign

    coreos-installer install /dev/vda -i coreos.ign

# If no valid tag is provided, treat this as a test server
else
    exit
fi

# Tell Vultr to eject the ISO. This will cause the server to reboot
echo "Rebooting"
vultr-cli server iso detach "$ID"
