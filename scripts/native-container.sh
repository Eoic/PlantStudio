#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"
if [[ -z "$mode" ]]; then
  echo "usage: $0 <build|smoke|screenshot>" >&2
  exit 2
fi

repo_root="/workspace"
project_dir="$repo_root/native-linux/app"
build_dir="$repo_root/native-linux/build"
binary_path="$build_dir/plantstudio-native"
display="${PLANTSTUDIO_NATIVE_DISPLAY:-:99}"
lock_file="/tmp/.X${display#:}-lock"
xvfb_pid=""
primary_config_path="/tmp/plantstudio-native-lazarus"

cleanup() {
  if [[ -n "$xvfb_pid" ]] && kill -0 "$xvfb_pid" 2>/dev/null; then
    kill "$xvfb_pid" 2>/dev/null || true
    wait "$xvfb_pid" 2>/dev/null || true
  fi
  rm -f "$lock_file"
}

build_app() {
  mkdir -p "$build_dir"
  mkdir -p "$primary_config_path"
  cd "$project_dir"
  lazbuild --primary-config-path="$primary_config_path" plantstudio_native.lpi
  if [[ -x "$project_dir/plantstudio_native" ]]; then
    cp "$project_dir/plantstudio_native" "$binary_path"
    chmod +x "$binary_path"
  fi
  if [[ ! -x "$binary_path" ]]; then
    echo "native binary not found after build: $binary_path" >&2
    exit 1
  fi
}

start_xvfb() {
  rm -f "$lock_file"
  Xvfb "$display" -screen 0 1280x960x24 -nolisten tcp >/tmp/plantstudio-native-xvfb.log 2>&1 &
  xvfb_pid="$!"
  sleep 1
  export DISPLAY="$display"
}

case "$mode" in
  build)
    build_app
    ;;
  smoke)
    trap cleanup EXIT
    build_app
    start_xvfb
    "$binary_path" \
      --file "$repo_root/for-olpc-python/test.pla" \
      --quit-after-render
    ;;
  screenshot)
    trap cleanup EXIT
    build_app
    start_xvfb
    mkdir -p "$repo_root/artifacts"
    "$binary_path" \
      --file "$repo_root/for-olpc-python/test.pla" \
      --screenshot "$repo_root/artifacts/native-linux-viewer.png" \
      --quit-after-render
    test -s "$repo_root/artifacts/native-linux-viewer.png"
    ;;
  *)
    echo "unknown mode: $mode" >&2
    exit 2
    ;;
esac
