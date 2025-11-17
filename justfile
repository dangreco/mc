mod tofu "just/tofu.just"
mod ansible "just/ansible.just"

[private]
default:
    @just --list

ssh:
    #!/usr/bin/env bash
    set -euo pipefail
    tmp=$(mktemp -d)
    trap "rm -rf $tmp" EXIT SIGINT SIGTERM

    # Get SSH key
    key=$(just tofu _get_ssh_key)
    echo "$key" > "$tmp/id_ed25519"
    chmod 600 "$tmp/id_ed25519"

    # Get IP
    ip=$(just tofu _get_ip_v4)

    ssh -i "$tmp/id_ed25519" root@"$ip"

deploy:
    #!/usr/bin/env bash
    set -euo pipefail
    ./scripts/deploy.sh
