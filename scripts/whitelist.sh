#!/usr/bin/env bash

root=$(git rev-parse --show-toplevel)
wl="$root/assets/whitelist.json"

tmp=$(mktemp)
trap 'rm -rf "$tmp"' EXIT SIGINT SIGTERM

add() {
    local username="$1"
    if [ -z "$username" ]; then
        echo "Error: Username cannot be empty"
        exit 1
    fi
    entry=$(curl -s "https://api.minecraftservices.com/minecraft/profile/lookup/name/$username" )
    entry=$(jq ' .uuid = .id | del(.id) ' <<<"$entry")
    jq --argjson e "$entry" 'map(select(.id != $e.id)) + [$e]' "$wl" > "$tmp"
    mv "$tmp" "$wl"
}

remove() {
    local username="$1"
    if [ -z "$username" ]; then
        echo "Error: Username cannot be empty"
        exit 1
    fi

    # Remove entry by username
    jq --arg name "$username" 'map(select(.name != $name))' "$wl" > "$tmp"
    mv "$tmp" "$wl"
}


cmd="$1"
shift 1
case "$cmd" in
    "add")
        add "$@"
        ;;
    "remove")
        remove "$@"
        ;;
    *)
        echo "Invalid command"
        exit 1
        ;;
esac
