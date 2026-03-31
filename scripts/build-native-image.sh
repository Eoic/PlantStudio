#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/native-common.sh"

repo_root="$(native_repo_root)"
engine="$(native_engine)"
image="$(native_image)"

exec "$engine" build \
  -f "$repo_root/native-linux/Containerfile" \
  -t "$image" \
  "$repo_root"
