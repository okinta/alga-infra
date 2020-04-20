#!/usr/bin/env bash

set -e

#
# Installs FCOS on a machine
#

export VULTR_API_KEY=$(cat /root/.bashrc | grep "export VULTR_API_KEY" | awk '{print $2}' | awk -F "=" '{print $2}')

export SSH_KEY="$(cat /root/.ssh/authorized_keys)"
echo "export SSH_KEY=\"$SSH_KEY\"" >> /root/.bashrc

export PRIVATE_IP="$(curl -s http://169.254.169.254/v1.json | jq '.interfaces[1].ipv4.address' | tr -d '"')"
echo "export PRIVATE_IP=\"$PRIVATE_IP\"" >> /root/.bashrc

# Who are we?
id="$(curl -s http://169.254.169.254/v1.json | jq '.instanceid' | tr -d '"')"
tag=$(vultr-cli server info $id | grep Tag | awk '{print $2}')

# Install vultrkv server
if [ $tag = "vultrkv" ]; then
    wget -q https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/coreos.fcc -O coreos.fcc.template
    wget -q https://raw.githubusercontent.com/okinta/vultrkv/master/coreos.fcc -O vultrkv.fcc

    envsubst < coreos.fcc.template > coreos.fcc
    yq merge coreos.fcc vultrkv.fcc | fcct > coreos.ign

    coreos-installer install /dev/vda -i coreos.ign

# Install a default FCOS server that we have root access to
elif [ $tag = "fcos" ]; then
    wget -q https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/coreos.fcc -O coreos.fcc.template
    envsubst < coreos.fcc.template > coreos.fcc
    echo "passwd:
  users:
    - name: regan
      groups:
        - sudo" > root.fcc
    yq merge coreos.fcc root.fcc | fcct > coreos.ign

    coreos-installer install /dev/vda -i coreos.ign

# If no valid tag is provided, treat this as a test server
else
    exit
fi

# Tell Vultr to eject the ISO. This will cause the server to reboot
echo "Rebooting"
vultr-cli server iso detach $id
