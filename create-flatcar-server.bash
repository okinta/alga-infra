#!/usr/bin/env bash

set -e

OS="CoreOS Stable"
PLAN="1024 MB RAM,25 GB SSD,1.00 TB BW"
REGION="Chicago"
SCRIPT="setup-flatcar"

OS_ID=$(vultr-cli os | grep "$OS" | awk '{print $1}')
REGION_ID=$(vultr-cli regions list | grep "$REGION" | awk '{print $1}')
SCRIPT_ID=$(vultr-cli script list | grep "$SCRIPT" | awk '{print $1}')
PLAN_ID=$(vultr-cli plans list | grep "$PLAN" | awk '{print $1}')

set -x
vultr-cli server create --region $REGION_ID --os $OS_ID --plan $PLAN_ID --private-network true --script-id $SCRIPT_ID
