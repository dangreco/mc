#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Usage: $0 <environment>"
  exit 1
fi

SECRETS="$(jq -r . "$1")"

AWS_ENDPOINT_URL_S3=$(echo "$SECRETS" | jq -r .b2.endpoint) \
    tofu -chdir=tofu destroy \
        -auto-approve \
        -var="secrets=$SECRETS"
