#!/usr/bin/env bash

set -e

OS="Ubuntu 18.04 x64"
PLAN="1024 MB RAM,25 GB SSD,1.00 TB BW"
REGION="New Jersey"
SCRIPT="create-live-iso"

OS_ID=$(vultr-cli os | grep "$APP" | awk '{print $1}')
REGION_ID=$(vultr-cli regions list | grep "$REGION" | awk '{print $1}')
SCRIPT_ID=$(vultr-cli script list | grep "$SCRIPT" | awk '{print $1}')
PLAN_ID=$(vultr-cli plans list | grep "$PLAN" | awk '{print $1}')

set -x
vultr-cli server create --region $REGION_ID --od $OS_ID --plan $PLAN_ID --script-id $SCRIPT_ID
