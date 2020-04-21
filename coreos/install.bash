#!/usr/bin/env bash

set -e

#
# Installs FCOS on a machine
#

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
wget -q https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/coreos.fcc -O coreos.fcc.template
envsubst < coreos.fcc.template > coreos.fcc

if [ "$TAG" = "vultrkv" ]; then
    echo "Installing vultrkv server"

    wget -q https://raw.githubusercontent.com/okinta/vultrkv/master/coreos.fcc -O vultrkv.fcc
    yq merge coreos.fcc vultrkv.fcc | fcct > coreos.ign
    coreos-installer install /dev/vda -i coreos.ign

elif [ "$TAG" = "fcos" ]; then
    echo "Installing default fcos server with root access"

    wget -q https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/root.fcc
    yq merge coreos.fcc root.fcc | fcct > coreos.ign
    coreos-installer install /dev/vda -i coreos.ign

# If no valid tag is provided, treat this as a test server
else
    exit
fi

# Tell Vultr to eject the ISO. This will cause the server to reboot
echo "Rebooting"
vultr-cli server iso detach "$ID"
