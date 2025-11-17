root    := `git rev-parse --show-toplevel`
module  := "tofu"

[private]
default:
    @just -f "{{module}}.just" --list

[private]
_output key exp:
    #!/usr/bin/env bash
    set -euo pipefail
    source "{{root}}/.env"
    tofu -chdir="{{root}}/tofu" output --json "{{key}}" | jq -r  "{{exp}}"

[private]
_get_ip_v4:
    #!/usr/bin/env bash
    set -euo pipefail
    just tofu _output "ip" ".subnet"

[private]
_get_ssh_key:
    #!/usr/bin/env bash
    set -euo pipefail
    just tofu _output "tls_private_key" ".private_key_openssh"

init:
    #!/usr/bin/env bash
    set -euo pipefail
    source "{{root}}/.env"
    tofu -chdir="{{root}}/tofu" init \
        -backend-config="bucket=$S3_BUCKET" \
        -backend-config="region=$S3_REGION" \
        -backend-config="endpoint=$S3_ENDPOINT"

plan:
    #!/usr/bin/env bash
    set -euo pipefail
    source "{{root}}/.env" || true
    tofu -chdir="{{root}}/tofu" plan -out=tfplan

apply:
    #!/usr/bin/env bash
    set -euo pipefail
    source "{{root}}/.env" || true
    tofu -chdir="{{root}}/tofu" apply -auto-approve tfplan

destroy:
    #!/usr/bin/env bash
    set -euo pipefail
    source "{{root}}/.env" || true
    tofu -chdir="{{root}}/tofu" destroy -auto-approve
