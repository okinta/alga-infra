#!/usr/bin/env bash

#
# Creates an ISO that will automatically call coreos/install.bash upon booting
#

# ARG_OPTIONAL_SINGLE([cloudflare-api-key],[],[The API key to use for updating Cloudflare DNS])
# ARG_OPTIONAL_SINGLE([cloudflare-email],[],[The email to use for updating Cloudflare DNS])
# ARG_OPTIONAL_SINGLE([container-registry-login],[],[The login for the private container registry])
# ARG_OPTIONAL_SINGLE([container-registry-name],[],[The name of the private container registry])
# ARG_OPTIONAL_SINGLE([container-registry-password],[],[The password for the private container registry])
# ARG_OPTIONAL_SINGLE([domain],[],[The domain that will host the ISO])
# ARG_OPTIONAL_SINGLE([logdna-ingestion-key],[],[The LogDNA Ingestion Key to use to forward logs])
# ARG_OPTIONAL_SINGLE([name],[],[The domain record name that will host the ISO])
# ARG_OPTIONAL_SINGLE([vultr-api-key],[],[The Vultr API key to use for communicating with Vultr])
# ARG_OPTIONAL_BOOLEAN([second-phase],[],[Whether or not this is the second phase for this script])
# ARG_DEFAULTS_POS([])
# ARG_HELP([Builds an ISO that can be used to install Fedora CoreOS])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.8.1 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info
# Generated online by https://argbash.io/generate


die()
{
    local _ret=$2
    test -n "$_ret" || _ret=1
    test "$_PRINT_HELP" = yes && print_help >&2
    echo "$1" >&2
    exit ${_ret}
}


begins_with_short_option()
{
    local first_option all_short_options='h'
    first_option="${1:0:1}"
    test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_cloudflare_api_key=
_arg_cloudflare_email=
_arg_container_registry_login=
_arg_container_registry_name=
_arg_container_registry_password=
_arg_domain=
_arg_logdna_ingestion_key=
_arg_name=
_arg_vultr_api_key=
_arg_second_phase="off"


print_help()
{
    printf '%s\n' "Builds an ISO that can be used to install Fedora CoreOS"
    printf 'Usage: %s [--cloudflare-api-key <arg>] [--cloudflare-email <arg>] [--container-registry-login <arg>] [--container-registry-name <arg>] [--container-registry-password <arg>] [--domain <arg>] [--logdna-ingestion-key <arg>] [--name <arg>] [--vultr-api-key <arg>] [--(no-)second-phase] [-h|--help]\n' "$0"
    printf '\t%s\n' "--cloudflare-api-key: The API key to use for updating Cloudflare DNS (no default)"
    printf '\t%s\n' "--cloudflare-email: The email to use for updating Cloudflare DNS (no default)"
    printf '\t%s\n' "--container-registry-login: The login for the private container registry (no default)"
    printf '\t%s\n' "--container-registry-name: The name of the private container registry (no default)"
    printf '\t%s\n' "--container-registry-password: The password for the private container registry (no default)"
    printf '\t%s\n' "--domain: The domain that will host the ISO (no default)"
    printf '\t%s\n' "--logdna-ingestion-key: The LogDNA Ingestion Key to use to forward logs (no default)"
    printf '\t%s\n' "--name: The domain record name that will host the ISO (no default)"
    printf '\t%s\n' "--vultr-api-key: The Vultr API key to use for communicating with Vultr (no default)"
    printf '\t%s\n' "--second-phase, --no-second-phase: Whether or not this is the second phase for this script (off by default)"
    printf '\t%s\n' "-h, --help: Prints help"
}


parse_commandline()
{
    while test $# -gt 0
    do
        _key="$1"
        case "$_key" in
            --cloudflare-api-key)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_cloudflare_api_key="$2"
                shift
                ;;
            --cloudflare-api-key=*)
                _arg_cloudflare_api_key="${_key##--cloudflare-api-key=}"
                ;;
            --cloudflare-email)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_cloudflare_email="$2"
                shift
                ;;
            --cloudflare-email=*)
                _arg_cloudflare_email="${_key##--cloudflare-email=}"
                ;;
            --container-registry-login)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_container_registry_login="$2"
                shift
                ;;
            --container-registry-login=*)
                _arg_container_registry_login="${_key##--container-registry-login=}"
                ;;
            --container-registry-name)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_container_registry_name="$2"
                shift
                ;;
            --container-registry-name=*)
                _arg_container_registry_name="${_key##--container-registry-name=}"
                ;;
            --container-registry-password)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_container_registry_password="$2"
                shift
                ;;
            --container-registry-password=*)
                _arg_container_registry_password="${_key##--container-registry-password=}"
                ;;
            --domain)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_domain="$2"
                shift
                ;;
            --domain=*)
                _arg_domain="${_key##--domain=}"
                ;;
            --logdna-ingestion-key)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_logdna_ingestion_key="$2"
                shift
                ;;
            --logdna-ingestion-key=*)
                _arg_logdna_ingestion_key="${_key##--logdna-ingestion-key=}"
                ;;
            --name)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_name="$2"
                shift
                ;;
            --name=*)
                _arg_name="${_key##--name=}"
                ;;
            --vultr-api-key)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_vultr_api_key="$2"
                shift
                ;;
            --vultr-api-key=*)
                _arg_vultr_api_key="${_key##--vultr-api-key=}"
                ;;
            --no-second-phase|--second-phase)
                _arg_second_phase="on"
                test "${1:0:5}" = "--no-" && _arg_second_phase="off"
                ;;
            -h|--help)
                print_help
                exit 0
                ;;
            -h*)
                print_help
                exit 0
                ;;
            *)
                _PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$1'" 1
                ;;
        esac
        shift
    done
}

parse_commandline "$@"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash
# ] <-- needed because of Argbash

export VULTR_API_KEY="$_arg_vultr_api_key"

function forward_logs {
    if [ -z "$_arg_logdna_ingestion_key" ]; then
        echo "LogDNA Ingestion Key not provided"
        return
    fi

    echo "deb https://repo.logdna.com stable main" | tee /etc/apt/sources.list.d/logdna.list
    wget -O- https://repo.logdna.com/logdna.gpg | apt-key add -
    apt update
    apt install -y logdna-agent
    logdna-agent -k "$_arg_logdna_ingestion_key"
    logdna-agent -f /tmp/firstboot.log
    logdna-agent -d /var/log
    logdna-agent -t buildiso
    update-rc.d logdna-agent defaults
    /etc/init.d/logdna-agent start
}

function upgrade {
    apt update
    apt upgrade -y
    apt autoremove -y
}

function setup_second_boot {
    # On boot, run this script again
    # shellcheck disable=SC2016
    {
        echo '#!/usr/bin/env bash'
        echo -n 'bash -c "$(curl -fsSL https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/create-live-iso.script.bash)" ""'
        echo -n " --vultr-api-key '$_arg_vultr_api_key'"
        echo -n " --cloudflare-email '$_arg_cloudflare_email'"
        echo -n " --cloudflare-api-key '$_arg_cloudflare_api_key'"
        echo -n " --domain '$_arg_domain'"
        echo -n " --name '$_arg_name'"
        echo -n " --container-registry-name '$_arg_container_registry_name'"
        echo -n " --container-registry-login '$_arg_container_registry_login'"
        echo -n " --container-registry-password '$_arg_container_registry_password'"
        echo -n " --second-phase"
        echo ' > /var/log/secondboot.log 2>&1'
    } > /etc/rc.local
    chmod +x /etc/rc.local
}

function install_tools {
    apt update
    apt install -y \
        gettext-base \
        jq \
        unzip

    # coreos-installer
    wget -q -O /usr/local/bin/coreos-installer \
        https://s3.okinta.ge/coreos-installer-ubuntu-0.2.1
    chmod +x /usr/local/bin/coreos-installer

    # fcct
    wget -q -O /usr/local/bin/fcct https://s3.okinta.ge/fcct-x86_64-unknown-linux-gnu-0.5.0
    chmod +x /usr/local/bin/fcct

    # yq
    wget -q -O /usr/local/bin/yq https://s3.okinta.ge/yq_linux_amd64_3.3.0
    chmod +x /usr/local/bin/yq

    # vultr-cli
    echo "export VULTR_API_KEY=$VULTR_API_KEY" >> /root/.bashrc
    wget -q -O vultr-cli.tar.gz https://s3.okinta.ge/vultr-cli_0.3.0_linux_64-bit.tar.gz
    tar -xzf vultr-cli.tar.gz -C /usr/local/bin
    chmod +x /usr/local/bin/vultr-cli
    rm -f vultr-cli.tar.gz

    # cf-update.sh
    echo "export CLOUDFLARE_API_KEY=$_arg_cloudflare_api_key" >> /root/.bashrc
    echo "export CLOUDFLARE_EMAIL=$_arg_cloudflare_email" >> /root/.bashrc
    local cf_version=7390200166fca82ea7d7e51c0fc843698e35a0cc
    wget -q -O cf-update.zip \
        "https://s3.okinta.ge/cloudflare-record-updater-$cf_version.zip"
    unzip -q -d /usr/local/src cf-update.zip
    rm -f cf-update.zip
    ln -s "/usr/local/src/cloudflare-record-updater-$cf_version/cf-update.sh" /usr/local/bin

    # Save container registry details
    local auth
    auth=$(echo -n "$_arg_container_registry_login:$_arg_container_registry_password" | base64)
    echo "export CONTAINER_REGISTRY=\"$_arg_container_registry_name\"" >> /root/.bashrc
    echo "export CONTAINER_REGISTRY_AUTH=\"$auth\"" >> /root/.bashrc
}

function setup_coreos {
    # On boot, run install-coreos.bash
    # shellcheck disable=SC2016
    echo '#!/usr/bin/env bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/install.bash)" > /var/log/install.log 2>&1' > /etc/rc.local
    chmod +x /etc/rc.local
}

function build_iso {
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
}

function upload_iso {
    local external_ip
    external_ip=$(ifconfig ens3 | grep "inet " | awk '{print $2}')

    # Update the DNS to point to this server
    cf-update.sh \
        "$_arg_cloudflare_email" \
        "$_arg_cloudflare_api_key" \
        "$_arg_domain" \
        "$_arg_name" \
        "$external_ip"

    # Host the ISO file so Vultr can download it
    apt install -y nginx
    ufw allow "Nginx HTTPS"
    local password
    password=$(openssl rand 9999 | sha256sum | awk '{print $1}')
    mkdir "/var/www/html/$password"
    mv /tmp/linux-x86_64.iso "/var/www/html/$password/installcoreos.iso"

    # Delete the old ISO if it exists
    local image_id
    image_id=$(vultr-cli iso private | grep installcoreos | awk '{print $1}')
    if [ -n "$image_id" ]; then
        vultr-cli iso delete "$image_id"
    fi

    # Tell Vultr to download the ISO
    local url="$_arg_name.$_arg_domain"
    vultr-cli iso create --url "https://$url/$password/installcoreos.iso"
    echo "Started upload"

    # Wait until the image has finished uploading
    local wait_for=60
    local max_timeout=$((wait_for * 10))
    local runtime=0
    image_id=""

    while true; do
        sleep $wait_for
        runtime=$((runtime + wait_for))

        if [ $runtime = $max_timeout ]; then
            echo "Timed out waiting for ISO to upload to Vultr" >&2
            break
        fi

        image_id=$(vultr-cli iso private | grep installcoreos | grep -v pending | awk '{print $1}')

        if [ -n "$image_id" ]; then
            echo "Finished uploading image. ID: $image_id"
            break
        fi
    done

    rm -rf "/var/www/html/$password"
}

function destroy_self {
    # Destroy self since our existence no longer serves any purpose
    local id
    id="$(curl -s http://169.254.169.254/v1.json | jq ".instanceid" | tr -d '"')"
    vultr-cli server delete "$id"
}

if [ $_arg_second_phase = off ]; then
    forward_logs
    upgrade
    setup_second_boot
    echo "Update complete. Rebooting"
    reboot

else
    echo "Running second phase"
    install_tools
    setup_coreos
    build_iso
    upload_iso
    destroy_self
fi
