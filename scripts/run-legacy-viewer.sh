#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/legacy-viewer-common.sh"

repo_root="$(legacy_repo_root)"
engine="$(legacy_engine)"
image="$(legacy_image)"

if [[ -z "${DISPLAY:-}" ]]; then
  echo "DISPLAY is not set. Use scripts/test-legacy-viewer.sh for headless verification." >&2
  exit 1
fi

if [[ "${SKIP_IMAGE_BUILD:-0}" != "1" ]]; then
  "$repo_root/scripts/build-legacy-image.sh"
fi

repo_mount="$(legacy_repo_mount "$repo_root" "$engine")"
x11_mount="/tmp/.X11-unix:/tmp/.X11-unix"
mapfile -t user_flags < <(legacy_container_user_flags)

if [[ "$(basename "$engine")" == "podman" ]]; then
  x11_mount="${x11_mount}:ro"
fi

exec "$engine" run --rm \
  "${user_flags[@]}" \
  -e DISPLAY \
  -v "$repo_mount" \
  -v "$x11_mount" \
  "$image" \
  bash -lc 'cd /workspace/for-olpc-python && python viewer.py'
