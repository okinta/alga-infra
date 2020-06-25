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
load_var CONTAINER_REGISTRY
load_var CONTAINER_REGISTRY_AUTH
load_var VULTR_API_KEY

# Who are we?
ID="$(curl -s http://169.254.169.254/v1.json | jq -r '.instanceid')"
export ID
echo "export ID=\"$ID\"" >> /root/.bashrc
TAG=$(vultr-cli server info "$ID" | grep Label | awk '{print $2}')
logdna-agent -t "$TAG"
export TAG
echo "export TAG=\"$TAG\"" >> /root/.bashrc
echo "Tag: $TAG"

# Configure this machine's private network
external_ip="$(curl -s http://169.254.169.254/v1.json | jq -r '.interfaces[0].ipv4.address')"
private_ip="$(curl -s http://169.254.169.254/v1.json | jq -r '.interfaces[1].ipv4.address')"
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

PRIVATE_IP="$(curl -s http://169.254.169.254/v1.json | jq -r '.interfaces[1].ipv4.address')"
export PRIVATE_IP
echo "export PRIVATE_IP=\"$PRIVATE_IP\"" >> /root/.bashrc

PRIVATE_SUBNET="$(sed "s/\.[^\.]*$//" <<< "$PRIVATE_IP").0"
export PRIVATE_SUBNET
echo "export PRIVATE_SUBNET=\"$PRIVATE_SUBNET\"" >> /root/.bashrc

# Get the base fcc config ready
userdata="$(curl -s http://169.254.169.254/user-data/user-data)"
wget -q -O coreos.fcc.template \
    https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/coreos.fcc
envsubst < coreos.fcc.template > coreos.fcc

# Enable root access if set
if [ "$(echo "$userdata" | jq -r '.root')" = true ]; then
    yq write -i coreos.fcc 'passwd.users[0].groups[+]' sudo
fi

# Configure the stacks
stacks="$(echo "$userdata" | jq -r '.stacks | .[]')"

if [ -z "$stacks" ]; then
    echo "No stacks provided. Done"
    exit
fi

for stack in $stacks; do
    echo "Installing $stack"

    # Update the DNS to point to this server
    if cf-update.sh \
        "$CLOUDFLARE_EMAIL" \
        "$CLOUDFLARE_API_KEY" \
        "okinta.ge" \
        "$stack.in" \
        "$private_ip"; then
        echo "Updated $stack.in.okinta.ge to point to $private_ip"
    fi

    wget -q "https://raw.githubusercontent.com/okinta/stack-$stack/master/coreos.fcc" -O "$stack.fcc"
done

# Install CoreOS
yq merge --append ./*.fcc | fcct > coreos.ign
coreos-installer install /dev/vda -i coreos.ign

# Update public DNS
for stack in $stacks; do
    if yq read "$stack.fcc" "passwd.users[*].name" | grep -w public; then
        cf-update.sh \
            "$CLOUDFLARE_EMAIL" \
            "$CLOUDFLARE_API_KEY" \
            "okinta.ge" \
            "$stack" \
            "$external_ip"
        echo "Updated $stack.okinta.ge to point to $external_ip"
    fi
done

# Tell Vultr to eject the ISO. This will cause the server to reboot
echo "Rebooting"
vultr-cli server iso detach "$ID"
