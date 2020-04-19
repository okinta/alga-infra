#!/usr/bin/env bash

#
# Installs coreos on a machine
#

# Who are we?
id="$(curl -s http://169.254.169.254/v1.json | jq '.instanceid' | tr -d '"')"
tag=$(vultr-cli server info $id | grep Tag | awk '{print $2}')

# Install flatcar if that's what the server is destined for
if [ $tag = "flatcar" ]; then
    wget https://raw.githubusercontent.com/flatcar-linux/init/flatcar-master/bin/flatcar-install
    chmod +x flatcar-install
    ./flatcar-install -d /dev/vda -C stable

# Or install Fedora CoreOS
elif [ $tag = "fcos" ]; then
    wget https://github.com/okinta/coreos-installer-docker/releases/download/0.1.3/coreos-installer
    chmod +x coreos-install
    ./coreos-installer install /dev/vda
    exit

# Otherwise install Red Hat CoreOS
else
    wget https://raw.github.com/coreos/init/master/bin/coreos-install
    chmod +x coreos-install
    ./coreos-install -d /dev/vda -C stable
fi

# Tell Vultr to eject the ISO. This will cause the server to reboot
echo "Rebooting"
vultr-cli server iso detach $id
