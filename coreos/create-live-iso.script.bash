#!/usr/bin/env bash

#
# Creates an ISO that will automatically call coreos/install.bash upon booting
#

export VULTR_API_KEY="$1"
if [ -z "$VULTR_API_KEY" ]; then
    echo "Vultr API key must be provided" >&2
    exit 1
fi

export LOGDNA_INGESTION_KEY="$2"
if [ -z "$LOGDNA_INGESTION_KEY" ]; then
    echo "LogDNA Ingestion Key must be provided" >&2
    exit 1
fi

# Forward logs
echo "deb https://repo.logdna.com stable main" | tee /etc/apt/sources.list.d/logdna.list
wget -O- https://repo.logdna.com/logdna.gpg | apt-key add -
apt update
apt install -y logdna-agent
sudo logdna-agent -k $LOGDNA_INGESTION_KEY
logdna-agent -d /var/log
logdna-agent -f /tmp/firstboot.log
logdna-agent -f /tmp/install.log
logdna-agent -t buildiso
update-rc.d logdna-agent defaults
/etc/init.d/logdna-agent start

# Install tools into the ISO that might be used
#

apt upgrade -y
apt autoremove -y
apt install -y \
    gettext-base \
    jq \
    unzip

# coreos-installer
wget -q -O /usr/local/bin/coreos-installer https://s3.okinta.ge/coreos-installer-ubuntu-0.1.3
chmod +x /usr/local/bin/coreos-installer

# fcct
wget -q -O /usr/local/bin/fcct https://s3.okinta.ge/fcct-x86_64-unknown-linux-gnu-0.5.0
chmod +x /usr/local/bin/fcct

# yq
wget -q -O /usr/local/bin/yq https://s3.okinta.ge/yq_linux_amd64_3.3.0
chmod +x /usr/local/bin/yq

# vultr-cli
echo "export VULTR_API_KEY=$1" >> /root/.bashrc
wget -q -O vultr-cli.tar.gz https://s3.okinta.ge/vultr-cli_0.3.0_linux_64-bit.tar.gz
tar -xzf vultr-cli.tar.gz -C /usr/local/bin
chmod +x /usr/local/bin/vultr-cli
rm -f vultr-cli.tar.gz

#
# Finished installing tools

# On boot, run install-coreos.bash
echo '#!/usr/bin/env bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/install.bash)" > /tmp/install.log 2>&1' > /etc/rc.local
chmod +x /etc/rc.local

# Build the ISO
apt install -y mkisofs
wget -q -O linux-live.zip https://s3.okinta.ge/linux-live-2.3.zip
unzip -q -d /tmp linux-live.zip
rm -f linux-live.zip

# Remove second boot option so we can boot immediately instead of waiting
head -13 /tmp/linux-live-2.3/bootfiles/syslinux.cfg > syslinux.cfg
mv syslinux.cfg /tmp/linux-live-2.3/bootfiles/syslinux.cfg

/tmp/linux-live-2.3/build
/tmp/gen_linux_iso.sh

# Host the ISO file so Vultr can download it
apt install -y nginx
ufw allow "Nginx HTTP"
mv /tmp/linux-x86_64.iso /var/www/html/installcoreos.iso

# Delete the old ISO if it exists
image_id=$(vultr-cli iso private | grep installcoreos | awk '{print $1}')
if ! [ -z "$image_id" ]; then
    vultr-cli iso delete "$image_id"
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
vultr-cli server delete "$id"
