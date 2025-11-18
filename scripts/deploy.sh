#!/usr/bin/env bash
set -euo pipefail

just tofu init
just tofu plan && just tofu apply

# Wait for host
ip=$(just tofu _get_ip_v4)
while ! nc -z $ip 22; do sleep 1; done

# Add ssh key to known hosts
ip=$(just tofu _get_ip_v4)
mkdir -p ~/.ssh
ssh-keyscan -H "$ip" >> ~/.ssh/known_hosts

just ansible apply
