#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/legacy-viewer-common.sh"

repo_root="$(legacy_repo_root)"
engine="$(legacy_engine)"
image="$(legacy_image)"

exec "$engine" build \
  -t "$image" \
  -f "$repo_root/linux-legacy/Containerfile" \
  "$repo_root"
