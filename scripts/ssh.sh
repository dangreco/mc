#!/usr/bin/env bash

TMP=$(mktemp -d)
cleanup() {
    rm -rf "$TMP"
}
trap cleanup EXIT SIGINT SIGTERM

# Create SSH private key file
PRIVATE_KEY=$(task tofu:output PATTERN=.tls_private_key.value.private_key_openssh)
PRIVATE_KEY_FILE="$TMP/idid_ed25519"
echo "$PRIVATE_KEY" > "$PRIVATE_KEY_FILE"
chmod 600 "$PRIVATE_KEY_FILE"

# Get IP
IP=$(task tofu:output PATTERN=.ip.value.subnet)

# SSH into the remote server
ssh -i "$PRIVATE_KEY_FILE" "root@$IP"
