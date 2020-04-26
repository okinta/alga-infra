#!/usr/bin/env bash

#
# Installs FCOS on a machine
#

# Configure this machine's private network
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

VULTR_API_KEY=$(grep "export VULTR_API_KEY" < /root/.bashrc | awk '{print $2}' | awk -F "=" '{print $2}')
export VULTR_API_KEY

SSH_KEY="$(cat /root/.ssh/authorized_keys)"
export SSH_KEY
echo "export SSH_KEY=\"$SSH_KEY\"" >> /root/.bashrc

PRIVATE_IP="$(curl -s http://169.254.169.254/v1.json | jq '.interfaces[1].ipv4.address' | tr -d '"')"
export PRIVATE_IP
echo "export PRIVATE_IP=\"$PRIVATE_IP\"" >> /root/.bashrc

PRIVATE_SUBNET="$(echo "$PRIVATE_IP" | sed "s/\.[^\.]*$//").0"
export PRIVATE_SUBNET
echo "export PRIVATE_SUBNET=\"$PRIVATE_SUBNET\"" >> /root/.bashrc

# Who are we?
ID="$(curl -s http://169.254.169.254/v1.json | jq '.instanceid' | tr -d '"')"
export ID
echo "export ID=\"$ID\"" >> /root/.bashrc
TAG=$(vultr-cli server info "$ID" | grep Tag | awk '{print $2}')
export TAG
echo "export TAG=\"$TAG\"" >> /root/.bashrc
echo "Tag: $TAG"

# Get the base fcc config ready
wget -q -O coreos.fcc.template \
    https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/coreos.fcc
envsubst < coreos.fcc.template > coreos.fcc

# If we're not establishing the Vault, then load our private registry credentials
if [ "$TAG" != "stack-vault" ]; then

    # Pull registry credentials from the Vault
    echo "Loading container registry credentials from Vault"
    login=$(timeout 5s curl -s http://vault.in.okinta.ge:7020/api/kv/registry_login)
    export REGISTRY_LOGIN

    if [ -v "$REGISTRY_LOGIN" ]; then
        echo "Could not connect to Vault"
        exit 1
    fi

    CONTAINER_REGISTRY=$(timeout 5s curl -s http://vault.in.okinta.ge:7020/api/kv/registry_name)
    export CONTAINER_REGISTRY

    password=$(timeout 5s curl -s http://vault.in.okinta.ge:7020/api/kv/registry_password)

    CONTAINER_REGISTRY_AUTH=$(echo -n "$login:$password" | base64 -e)
    export CONTAINER_REGISTRY_AUTH

    # Inject the registry credentials into the coreos configuration
    wget -q -O registry.fcc.template \
        https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/registry.fcc
    envsubst < registry.fcc.template > registry.fcc
    yq merge --append coreos.fcc registry.fcc > coreos.merged.fcc
    mv coreos.merged.fcc coreos.fcc
    rm -f registry.fc*
    echo "Injected container registry credentials into ignition config"
fi

if [[ "$TAG" == stack* ]]; then
    echo "Installing $TAG"

    wget -q "https://raw.githubusercontent.com/okinta/$TAG/master/coreos.fcc" -O stack.fcc
    yq merge --append coreos.fcc stack.fcc | fcct > coreos.ign
    coreos-installer install /dev/vda -i coreos.ign

elif [ "$TAG" = "fcos" ]; then
    echo "Installing default fcos server with root access"

    wget -q -O root.fcc.template \
        https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/root.fcc
    envsubst < root.fcc.template > root.fcc

    # Replace the user and add a user with root permission
    yq delete coreos.fcc passwd.users > coreos.nousers.fcc
    yq merge --append coreos.nousers.fcc root.fcc | fcct > coreos.ign

    coreos-installer install /dev/vda -i coreos.ign

# If no valid tag is provided, treat this as a test server
else
    exit
fi

# Tell Vultr to eject the ISO. This will cause the server to reboot
echo "Rebooting"
vultr-cli server iso detach "$ID"
