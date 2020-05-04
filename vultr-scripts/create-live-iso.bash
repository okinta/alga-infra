#!/usr/bin/env bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/okinta/vultr-scripts/master/coreos/create-live-iso.script.bash)" "" \
    "[VULTR_API_KEY]" \
    "[CLOUDFLARE_EMAIL]" \
    "[CLOUDFLARE_API_KEY]" \
    "[CLOUDFLARE_ZONENAME]" \
    "[CLOUDFLARE_RECORDNAME]" \
    "--logdna-ingestion-key" "[LOGDNA_INGESTION_KEY]"
