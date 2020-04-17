#!/usr/bin/env bash

set -e

#
# Configures the server's private IP and sets zsh as the default shell
#

if [ -z "$1" ]; then
    echo "Vultr API key must be provided"
    exit 1
fi

# Set up Vultr CLI so we can find our internal IP
export VULTR_API_KEY="$1"
VULTR_CLI_VERSION="0.3.0"
wget "https://github.com/vultr/vultr-cli/releases/download/v0.3.0/vultr-cli_${VULTR_CLI_VERSION}_linux_64-bit.tar.gz"
tar -xzf "vultr-cli_${VULTR_CLI_VERSION}_linux_64-bit.tar.gz"
mv ./vultr-cli /usr/local/bin/
rm -f "vultr-cli_${VULTR_CLI_VERSION}_linux_64-bit.tar.gz"

# Now find this machine's private IP
external_ip=$(ifconfig ens3 | grep "inet " | awk '{print $2}')
private_ip=""
for id in $(vultr-cli server list | awk '{print $1}' | egrep '[0-9]+'); do
    main_ip=$(vultr-cli server info $id | grep "Main IP" | awk '{print $3}')
    if [ $main_ip = $external_ip ]; then
        break
    fi
done

if [ -z "$private_ip" ]; then
    echo "Can't find private IP"
    exit 1
fi

# Configure this machine's private network
echo "network:
  version: 2
  renderer: networkd
  ethernets:
    ens7:
      mtu: 1450
      dhcp4: no
      addresses: [$private_ip/16]" > /etc/netplan/10-ens7.yaml
netplan apply

# Install zsh and Oh My Zsh
apt update
apt install -y zsh
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
