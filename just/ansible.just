root    := `git rev-parse --show-toplevel`
module  := "ansible"

[private]
default:
    @just -f "{{module}}.just" --list

ping:
    #!/usr/bin/env bash
    set -euo pipefail
    tmp=$(mktemp -d)
    trap "rm -rf $tmp" EXIT SIGINT SIGTERM

    # Get SSH key
    key=$(just tofu _get_ssh_key)
    echo "$key" > "$tmp/id_ed25519"
    chmod 600 "$tmp/id_ed25519"

    ansible all \
        -m ping \
        --inventory "../ansible/inventory.yml" \
        --private-key "$tmp/id_ed25519"

apply:
    #!/usr/bin/env bash
    set -euo pipefail
    tmp=$(mktemp -d)
    trap "rm -rf $tmp" EXIT SIGINT SIGTERM

    # Get SSH key
    key=$(just tofu _get_ssh_key)
    echo "$key" > "$tmp/id_ed25519"
    chmod 600 "$tmp/id_ed25519"

    # Install requirements
    ansible-galaxy install -r ../ansible/requirements.yml

    # Run site.yml
    ansible-playbook ../ansible/site.yml \
        --inventory "../ansible/inventory.yml" \
        --private-key "$tmp/id_ed25519"
