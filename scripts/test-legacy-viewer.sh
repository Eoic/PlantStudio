#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/legacy-viewer-common.sh"

repo_root="$(legacy_repo_root)"
engine="$(legacy_engine)"
image="$(legacy_image)"

if [[ "${SKIP_IMAGE_BUILD:-0}" != "1" ]]; then
  "$repo_root/scripts/build-legacy-image.sh"
fi

repo_mount="$(legacy_repo_mount "$repo_root" "$engine")"
mapfile -t user_flags < <(legacy_container_user_flags)

exec "$engine" run --rm \
  "${user_flags[@]}" \
  -v "$repo_mount" \
  "$image" \
  bash /workspace/scripts/legacy-viewer-container.sh smoke
