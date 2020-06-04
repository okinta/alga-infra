#!/usr/bin/env bash

function wait {
    if [ -z "$1" ]; then
        echo "IP must be provided" >&2
        return
    fi

    ip="$1"
    while true; do
        sleep 10
        if timeout 10s ssh -oStrictHostKeyChecking=no "$ip" exit &> /dev/null
        then
            break
        fi
    done

    ssh-keygen -f "$HOME/.ssh/known_hosts" -R "$ip" &> /dev/null
    echo "Server is ready"
}

echo "Starting server; waiting for it to come online"
output=$(agrix provision infra/vault.yaml 2>&1 | tee /dev/tty)
id=$(grep "Provisioned server with ID" <<< "$output" | awk '{print $NF}')

# Find the IP of the new server
sleep 1
ip=$(vultr-cli server info "$id" | grep "Main IP" | awk '{print $3}')
while [ -z "$ip" ] || [ "$ip" = "0.0.0.0" ]; do
    sleep 1
    ip=$(vultr-cli server info "$id" | grep "Main IP" | awk '{print $3}')
done
echo "Vault server IP is $ip"

wait "$ip"

# Accept the machine's key
ssh -oStrictHostKeyChecking=no "$ip" exit

# Run the script (keep running until we get confirmation)
output=$(ssh "$ip" 'bash -s' < ./vault-commands.sh)
until [[ "$output" == *"key was successfully"* ]]; do
    sleep 1
    output=$(ssh "$ip" 'bash -s' < ./vault-commands.sh)
done
ssh "$ip" 'bash -s' < ./vault-commands.sh
echo
echo "Ready"
