#!/usr/bin/env bash

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
