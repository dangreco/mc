#!/usr/bin/env bash

# Install requirements
ansible-galaxy install -r ansible/requirements.yml

# Check site.yml
ansible-playbook ansible/site.yml \
    --inventory ansible/inventory.yml \
    --syntax-check
