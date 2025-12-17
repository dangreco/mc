#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Usage: $0 <environment>"
  exit 1
fi

SECRETS="$(jq -r . "$1")"

AWS_ENDPOINT_URL_S3=$(echo "$SECRETS" | jq -r .b2.endpoint) \
    tofu -chdir=tofu init \
        -backend-config="bucket=$(echo "$SECRETS" | jq -r .b2.bucket)" \
        -backend-config="region=$(echo "$SECRETS" | jq -r .b2.region)" \
        -backend-config="access_key=$(echo "$SECRETS" | jq -r .b2.application_key_id)" \
        -backend-config="secret_key=$(echo "$SECRETS" | jq -r .b2.application_key)"
