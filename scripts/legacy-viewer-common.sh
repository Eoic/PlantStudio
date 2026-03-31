#!/usr/bin/env bash

legacy_repo_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

legacy_engine() {
  printf '%s\n' "${CONTAINER_ENGINE:-podman}"
}

legacy_image() {
  printf '%s\n' "${PLANTSTUDIO_LEGACY_IMAGE:-plantstudio-legacy:ubuntu18.04}"
}

legacy_repo_mount() {
  local repo_root="$1"
  local engine="$2"
  local mount_spec="${repo_root}:/workspace"

  if [[ "$(basename "$engine")" == "podman" ]]; then
    mount_spec="${mount_spec}:Z"
  fi

  printf '%s\n' "$mount_spec"
}

legacy_container_user_flags() {
  printf -- '--user\n%s:%s\n' "$(id -u)" "$(id -g)"
}
