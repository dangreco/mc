#!/usr/bin/env bash
set -euo pipefail

just tofu plan && just tofu apply
just ansible apply
