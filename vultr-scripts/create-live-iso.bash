#!/usr/bin/env bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/create-live-iso.script.bash)" "" \
    "--vultr-api-key" "[VULTR_API_KEY]" \
    "--cloudflare-email" "[CLOUDFLARE_EMAIL]" \
    "--cloudflare-api-key" "[CLOUDFLARE_API_KEY]" \
    "--domain" "[CLOUDFLARE_ZONENAME]" \
    "--name" "[CLOUDFLARE_RECORDNAME]" \
    "--container-registry-name" "[CONTAINER_REGISTRY_NAME]" \
    "--container-registry-login" "[CONTAINER_REGISTRY_LOGIN]" \
    "--container-registry-password" "[CONTAINER_REGISTRY_PASSWORD]" \
    "--logdna-ingestion-key" "[LOGDNA_INGESTION_KEY]"
