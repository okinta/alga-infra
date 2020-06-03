#!/usr/bin/env bash

apt update
apt install -y jq

userdata="$(curl -s http://169.254.169.254/user-data/user-data)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/create-live-iso.script.bash)" "" \
    "--vultr-api-key" "$(echo "$userdata" | jq -r '.VULTR_API_KEY')" \
    "--cloudflare-email" "$(echo "$userdata" | jq -r '.CLOUDFLARE_EMAIL')" \
    "--cloudflare-api-key" "$(echo "$userdata" | jq -r '.CLOUDFLARE_API_KEY')" \
    "--domain" "$(echo "$userdata" | jq -r '.CLOUDFLARE_ZONENAME')" \
    "--name" "$(echo "$userdata" | jq -r '.CLOUDFLARE_RECORDNAME')" \
    "--container-registry-name" "$(echo "$userdata" | jq -r '.CONTAINER_REGISTRY_NAME')" \
    "--container-registry-login" "$(echo "$userdata" | jq -r '.CONTAINER_REGISTRY_LOGIN')" \
    "--container-registry-password" "$(echo "$userdata" | jq -r '.CONTAINER_REGISTRY_PASSWORD')" \
    "--logdna-ingestion-key" "$(echo "$userdata" | jq -r '.LOGDNA_INGESTION_KEY')"
