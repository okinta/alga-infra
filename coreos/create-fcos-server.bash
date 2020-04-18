#!/usr/bin/env bash

set -e

ISO="installcoreos.iso"
PLAN="1024 MB RAM,25 GB SSD,1.00 TB BW"
REGION="Chicago"
TAG="fcos"

ISO_ID=$(vultr-cli iso private | grep "$ISO" | awk '{print $1}')
REGION_ID=$(vultr-cli regions list | grep "$REGION" | awk '{print $1}')
PLAN_ID=$(vultr-cli plans list | grep "$PLAN" | awk '{print $1}')

set -x
vultr-cli server create --region $REGION_ID --iso $ISO_ID --plan $PLAN_ID --private-network true --tag $TAG
