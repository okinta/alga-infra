#!/usr/bin/env bash

#
# Upgrades CoreOS to Flatcar
#

if [ -z "$1" ]; then
    echo "Vultr API key must be provided"
    exit 1
fi

# Update to latest flatcar release
wget https://docs.flatcar-linux.org/update-to-flatcar.sh
chmod +x update-to-flatcar.sh
./update-to-flatcar.sh
rm -f update-to-flatcar.sh

# Set up Vultr CLI so we can find our internal IP
export VULTR_API_KEY="$1"
VULTR_CLI_VERSION="0.3.0"
wget "https://github.com/vultr/vultr-cli/releases/download/v0.3.0/vultr-cli_${VULTR_CLI_VERSION}_linux_64-bit.tar.gz"
tar -xzf "vultr-cli_${VULTR_CLI_VERSION}_linux_64-bit.tar.gz"
mv ./vultr-cli /usr/local/bin/
rm -f "vultr-cli_${VULTR_CLI_VERSION}_linux_64-bit.tar.gz"

# Now find this machine's private IP
external_ip=$(ifconfig ens3 | grep "inet " | awk '{print $2}')
id=$(vultr-cli server list | grep "$external_ip" | awk '{print $1}')
if [ -z "$id" ]; then
    echo "Can't find server"
    exit 1
fi

private_ip=$(vultr-cli server info $id | grep "Internal IP" | awk '{print $3}')

# Set up Vultr private networking
echo "[Match]
Name=eth1

[Link]
MTUBytes=1450

[Network]
Address=$private_ip/16" > /etc/systemd/network/static.network
chmod 0644 /etc/systemd/network/static.network
systemctl restart systemd-networkd

# Done
systemctl reboot
