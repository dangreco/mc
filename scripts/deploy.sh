#!/usr/bin/env bash

TMP=$(mktemp -d)
cleanup() {
    rm -rf "$TMP"
}
trap cleanup EXIT SIGINT SIGTERM

# Apply OpenTofu configuration
task tofu:plan PLAN="$TMP/plan"
task tofu:apply PLAN="$TMP/plan"

# Wait for SSH to be available on remote
IP=$(task tofu:output PATTERN=.ip.value.subnet)
while ! nc -z $IP 22; do sleep 1; done

# Add SSH key to known hosts
mkdir -p ~/.ssh
ssh-keyscan -H "$IP" >> ~/.ssh/known_hosts

# Run Ansible playbook
task ansible:apply
