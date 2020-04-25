#!/usr/bin/env bash

while true; do
    sleep 10
    timeout 10s ssh -oStrictHostKeyChecking=no "$1" exit &> /dev/null
    if [ $? -eq 0 ]; then
        break
    fi
done

ssh-keygen -f "~/.ssh/known_hosts" -R "$1" &> /dev/null
echo "Server is ready"
