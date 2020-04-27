#!/usr/bin/env bash

echo "Starting server; waiting for it to come online"
output=$(./server stack-vault --wait 2>&1 | tee /dev/tty)
ip=$(grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" <<< "$output")
ssh -oStrictHostKeyChecking=no "$ip" exit
sleep 5
ssh "$ip" 'bash -s' < ./vault-commands.sh
echo
echo "Ready"
