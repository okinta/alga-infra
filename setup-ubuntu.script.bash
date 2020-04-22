#!/usr/bin/env bash

set -e

#
# Configures the server's private IP and sets zsh as the default shell
#

# Configure this machine's private network
apt install -y jq
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

# Install zsh and Oh My Zsh
apt update
apt install -y zsh
chsh -s $(which zsh)
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
HOME="/root" ZSH="/root/.oh-my-zsh" sh install.sh
rm -f install.sh
echo "Finished configuring zsh"

# Install the GUI
apt install -y xorg
apt install -y --no-install-recommends lightdm-gtk-greeter
apt install -y --no-install-recommends lightdm
apt install -y --no-install-recommends lxde-icon-theme
apt install -y --no-install-recommends lxde-core
apt install -y --no-install-recommends lxde-common
apt install -y --no-install-recommends policykit-1 lxpolkit
apt install -y --no-install-recommends lxsession-logout
apt install -y --no-install-recommends gvfs-backends

# Update to latest software then reboot
apt upgrade -y
apt autoremove -y
apt-get autoclean -y
echo "Done updating. Rebooting."
reboot now
