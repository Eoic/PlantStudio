#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/native-common.sh"

repo_root="$(native_repo_root)"
engine="$(native_engine)"
image="$(native_image)"
container_home="$(native_container_home)"

if [[ "${SKIP_IMAGE_BUILD:-0}" != "1" ]]; then
  "$repo_root/scripts/build-native-image.sh"
fi

mkdir -p "$repo_root/artifacts"
rm -f "$repo_root/artifacts/native-linux-viewer.png"

repo_mount="$(native_repo_mount "$repo_root" "$engine")"

exec "$engine" run --rm \
  -e "HOME=$container_home" \
  -v "$repo_mount" \
  "$image" \
  bash /workspace/scripts/native-container.sh screenshot
