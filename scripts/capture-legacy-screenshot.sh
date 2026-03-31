#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/legacy-viewer-common.sh"

repo_root="$(legacy_repo_root)"
engine="$(legacy_engine)"
image="$(legacy_image)"
screenshot_dir="$repo_root/artifacts"
screenshot_path="$screenshot_dir/legacy-viewer.png"
container_name="plantstudio-legacy-capture-$$"

if [[ "${SKIP_IMAGE_BUILD:-0}" != "1" ]]; then
  "$repo_root/scripts/build-legacy-image.sh"
fi

mkdir -p "$screenshot_dir"
rm -f "$screenshot_path"

repo_mount="$(legacy_repo_mount "$repo_root" "$engine")"
mapfile -t user_flags < <(legacy_container_user_flags)

cleanup() {
  "$engine" rm -f "$container_name" >/dev/null 2>&1 || true
}

trap cleanup EXIT

"$engine" create \
  --name "$container_name" \
  "${user_flags[@]}" \
  -v "$repo_mount" \
  "$image" \
  bash -lc 'export PLANTSTUDIO_LEGACY_SCREENSHOT_PATH=/tmp/legacy-viewer.png; /workspace/scripts/legacy-viewer-container.sh screenshot' >/dev/null

"$engine" start -a "$container_name"
"$engine" cp "$container_name:/tmp/legacy-viewer.png" "$screenshot_path"

test -s "$screenshot_path"
echo "Wrote $screenshot_path."
