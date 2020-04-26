#!/usr/bin/env bash

output=$(./server stack-vault)
echo "$output"
ip=$(tail -1 <<< "$output")
echo "Started server; waiting for it to come online"
./wait.sh "$ip"
echo "Vault is online; loading data"
ssh -oStrictHostKeyChecking=no "$ip" exit
ssh "$ip" 'bash -s' < ./vault-commands.sh
echo
echo "Ready"
