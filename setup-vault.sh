#!/usr/bin/env bash

ip=$(./server stack-vault | tail -1)
echo "Started server; waiting for it to come online"
./wait.sh "$ip"
echo "Vault is online; loading data"
ssh -oStrictHostKeyChecking=no "$ip" 'bash -s' < ./vault-commands.sh
echo
echo "Ready"
