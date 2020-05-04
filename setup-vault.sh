#!/usr/bin/env bash

echo "Starting server; waiting for it to come online"
output=$(./server stack-vault --wait 2>&1 | tee /dev/tty)
ip=$(grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" <<< "$output")

# Accept the machine's key
ssh -oStrictHostKeyChecking=no "$ip" exit

# Run the script (keep running until we get confirmation)
output=$(ssh "$ip" 'bash -s' < ./vault-commands.sh)
until [[ "$output" == *"key was successfully"* ]]; do
    output=$(ssh "$ip" 'bash -s' < ./vault-commands.sh)
done
ssh "$ip" 'bash -s' < ./vault-commands.sh
echo
echo "Ready"
