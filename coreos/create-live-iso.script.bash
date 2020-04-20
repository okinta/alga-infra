#!/usr/bin/env bash

set -e

#
# Creates an ISO that will automatically call coreos/install.bash upon booting
#

if [ -z "$1" ]; then
    echo "Vultr API key must be provided" >&2
    exit 1
fi

# Install tools into the ISO that might be used
#

apt install -y jq unzip

# coreos-installer
wget -q https://github.com/okinta/coreos-installer-docker/releases/download/0.1.3/coreos-installer
chmod +x coreos-installer
mv coreos-installer /usr/local/bin

# envsubst
curl -sL https://github.com/a8m/envsubst/releases/download/v1.1.0/envsubst-`uname -s`-`uname -m` -o envsubst
chmod +x envsubst
mv envsubst /usr/local/bin

# fcct
wget -q https://github.com/coreos/fcct/releases/download/v0.5.0/fcct-x86_64-unknown-linux-gnu
chmod +x fcct-x86_64-unknown-linux-gnu
mv fcct-x86_64-unknown-linux-gnu /usr/local/bin/fcct

# yq
wget -q https://github.com/mikefarah/yq/releases/download/3.3.0/yq_linux_amd64
chmod +x yq_linux_amd64
mv yq_linux_amd64 /usr/local/bin/yq

# vultr-cli
export VULTR_API_KEY="$1"
echo "export VULTR_API_KEY=$1" >> /root/.bashrc
VULTR_CLI_VERSION="0.3.0"
wget -q "https://github.com/vultr/vultr-cli/releases/download/v0.3.0/vultr-cli_${VULTR_CLI_VERSION}_linux_64-bit.tar.gz"
tar -xzf "vultr-cli_${VULTR_CLI_VERSION}_linux_64-bit.tar.gz"
mv ./vultr-cli /usr/local/bin/
rm -f "vultr-cli_${VULTR_CLI_VERSION}_linux_64-bit.tar.gz"

#
# Finished installing tools

# On boot, run install-coreos.bash
echo '#!/usr/bin/env bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/install.bash)" > /tmp/install.log 2>&1' > /etc/rc.local
chmod +x /etc/rc.local

# Build the ISO
VERSION="2.3"
apt install -y mkisofs unzip
wget "https://github.com/Tomas-M/linux-live/archive/v$VERSION.zip"
unzip "v$VERSION.zip"
mv "linux-live-$VERSION" /tmp
rm -f "v$VERSION.zip"
/tmp/linux-live-$VERSION/build
/tmp/gen_linux_iso.sh

# Host the ISO file so Vultr can download it
apt install -y nginx
ufw allow "Nginx HTTP"
mv /tmp/linux-x86_64.iso /var/www/html/installcoreos.iso

# Delete the old ISO if it exists
image_id=$(vultr-cli iso private | grep installcoreos | awk '{print $1}')
if ! [ -z "$image_id" ]; then
    vultr-cli iso delete $image_id
fi

# Tell Vultr to download the ISO
external_ip=$(ifconfig ens3 | grep "inet " | awk '{print $2}')
vultr-cli iso create --url "http://$external_ip/installcoreos.iso"
echo "Started upload"

# Wait until the image has finished uploading
sleep 60
image_id=$(vultr-cli iso private | grep installcoreos | awk '{print $1}')
while [ -z "$image_id" ]; do
    image_id=$(vultr-cli iso private | grep installcoreos | awk '{print $1}')
    sleep 60
done

# Destroy self since our existence no longer serves any purpose
id="$(curl -s http://169.254.169.254/v1.json | jq ".instanceid" | tr -d '"')"
vultr-cli server delete $id
