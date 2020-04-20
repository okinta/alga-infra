#!/usr/bin/env bash

set -e

#
# Installs FCOS on a machine
#

wget -q "https://github.com/okinta/coreos-installer-docker/releases/download/0.1.3/coreos-installer"
chmod +x coreos-installer

export VULTR_API_KEY=$(cat /root/.bashrc | grep "export VULTR_API_KEY" | awk '{print $2}' | awk -F "=" '{print $2}')

export SSH_KEY="$(cat /root/.ssh/authorized_keys)"
echo "export SSH_KEY=\"$SSH_KEY\"" >> /root/.bashrc

# Who are we?
id="$(curl -s http://169.254.169.254/v1.json | jq '.instanceid' | tr -d '"')"
tag=$(vultr-cli server info $id | grep Tag | awk '{print $2}')

if [ $tag = "vultrkv" ]; then
    wget -q https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/coreos.fcc
    wget -q https://raw.githubusercontent.com/okinta/vultrkv/master/coreos.fcc -O vultrkv.fcc
    spiff merge coreos.fcc vultrkv.fcc | fcct > coreos.ign

    ./coreos-installer install /dev/vda -i coreos.ign

# If no valid tag is provided, treat this as a test server
else
    exit
fi

# Tell Vultr to eject the ISO. This will cause the server to reboot
echo "Rebooting"
vultr-cli server iso detach $id
