#!/usr/bin/env bash

#
# Creates an ISO that will automatically call coreos/install.bash upon booting
#

if [ -z "$1" ]; then
    echo "Vultr API key must be provided"
    exit 1
fi

# Save the Vultr API key inside the ISO so we have access to it later when a
# server boots
export VULTR_API_KEY="$1"
echo "export VULTR_API_KEY=$1" >> /root/.bashrc

# On boot, run install-coreos.bash
cat > /etc/rc.local <<EOL
#!/usr/bin/env bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/install.bash)" > /tmp/install.log
EOL
chmod +x /etc/rc.local

# Build the ISO
VERSION="2.3"
apt install -y mkisofs nginx unzip
wget "https://github.com/Tomas-M/linux-live/archive/v$VERSION.zip"
unzip "v$VERSION.zip"
mv "linux-live-$VERSION" /tmp
rm -f "v$VERSION.zip"
/tmp/linux-live-$VERSION/build
/tmp/gen_linux_iso.sh

# Host the ISO file so Vultr can download it
ufw allow "Nginx HTTP"
mv /tmp/linux-x86_64.iso /var/www/html/installcoreos.iso

# Set up Vultr CLI so we can upload the ISO we just created
VULTR_CLI_VERSION="0.3.0"
wget "https://github.com/vultr/vultr-cli/releases/download/v0.3.0/vultr-cli_${VULTR_CLI_VERSION}_linux_64-bit.tar.gz"
tar -xzf "vultr-cli_${VULTR_CLI_VERSION}_linux_64-bit.tar.gz"
mv ./vultr-cli /usr/local/bin/
rm -f "vultr-cli_${VULTR_CLI_VERSION}_linux_64-bit.tar.gz"

# Delete the old ISO if it exists
image_id=$(vultr-cli iso private | grep installcoreos | awk '{print $1}')
if ! [ -z "$image_id" ]; then
    vultr-cli iso delete $image_id
fi

# Tell Vultr to download the ISO
external_ip=$(ifconfig ens3 | grep "inet " | awk '{print $2}')
vultr-cli iso create --url "http://$external_ip/installcoreos.iso"
echo "Started upload"
