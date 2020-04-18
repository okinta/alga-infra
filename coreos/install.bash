#!/usr/bin/env bash

#
# Installs coreos on a machine
#

wget https://raw.github.com/coreos/init/master/bin/coreos-install
chmod +x coreos-install
./coreos-install -d /dev/vda -C stable

# Set up Vultr CLI so we can eject the ISO and boot into coreos
VULTR_CLI_VERSION="0.3.0"
wget "https://github.com/vultr/vultr-cli/releases/download/v0.3.0/vultr-cli_${VULTR_CLI_VERSION}_linux_64-bit.tar.gz"
tar -xzf "vultr-cli_${VULTR_CLI_VERSION}_linux_64-bit.tar.gz"
mv ./vultr-cli /usr/local/bin/
rm -f "vultr-cli_${VULTR_CLI_VERSION}_linux_64-bit.tar.gz"

# Tell Vultr to eject the ISO. This will cause the server to reboot
export VULTR_API_KEY=$(cat /root/.bashrc | grep "export VULTR_API_KEY" | awk '{print $2}' | awk -F "=" '{print $2}')
external_ip=$(ifconfig ens3 | grep "inet " | awk '{print $2}')
id=$(vultr-cli server list | grep "$external_ip" | awk '{print $1}')
if [ -z "$id" ]; then
    echo "Can't find server"
    exit 1
fi
echo "Rebooting"
vultr-cli server iso detach $id
