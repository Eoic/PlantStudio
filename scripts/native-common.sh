#!/usr/bin/env bash

native_repo_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

native_engine() {
  printf '%s\n' "${CONTAINER_ENGINE:-podman}"
}

native_image() {
  printf '%s\n' "${PLANTSTUDIO_NATIVE_IMAGE:-plantstudio-native:ubuntu24.04}"
}

native_container_home() {
  printf '%s\n' "/workspace/native-linux/.container-home"
}

native_repo_mount() {
  local repo_root="$1"
  local engine="$2"
  local mount_spec="${repo_root}:/workspace"

  if [[ "$(basename "$engine")" == "podman" ]]; then
    mount_spec="${mount_spec}:Z"
  fi

  printf '%s\n' "$mount_spec"
}
