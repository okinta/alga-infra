#!/usr/bin/env bash

#
# Installs coreos on a machine
#

apt install -y jq

# Set up Vultr CLI
VULTR_CLI_VERSION="0.3.0"
wget "https://github.com/vultr/vultr-cli/releases/download/v0.3.0/vultr-cli_${VULTR_CLI_VERSION}_linux_64-bit.tar.gz"
tar -xzf "vultr-cli_${VULTR_CLI_VERSION}_linux_64-bit.tar.gz"
mv ./vultr-cli /usr/local/bin/
rm -f "vultr-cli_${VULTR_CLI_VERSION}_linux_64-bit.tar.gz"
export VULTR_API_KEY=$(cat /root/.bashrc | grep "export VULTR_API_KEY" | awk '{print $2}' | awk -F "=" '{print $2}')

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
    apt install -y cargo
    cargo install coreos-installer
    coreos-installer install /dev/vda

# Otherwise install Red Hat CoreOS
else
    wget https://raw.github.com/coreos/init/master/bin/coreos-install
    chmod +x coreos-install
    ./coreos-install -d /dev/vda -C stable
fi

# Tell Vultr to eject the ISO. This will cause the server to reboot
echo "Rebooting"
vultr-cli server iso detach $id
