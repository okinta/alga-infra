#!/usr/bin/env bash

function assert_repo_exists {
    if [ -z "$1" ]; then
        echo "Repo must be provided" >&2
        exit 1
    fi

    url="https://github.com/okinta/$1/blob/master/coreos.fcc"
    if curl --output /dev/null --silent --head --fail "$url"; then
        true
    else
        die "$1 does not exist"
    fi
}

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
