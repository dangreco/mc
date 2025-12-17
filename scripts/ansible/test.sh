#!/usr/bin/env bash

# Check site.yml
ansible-playbook ansible/site.yml \
    --inventory ansible/inventory.yml \
    --syntax-check
