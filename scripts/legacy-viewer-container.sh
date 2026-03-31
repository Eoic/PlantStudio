#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"
if [[ -z "$mode" ]]; then
  echo "usage: $0 <smoke|screenshot>" >&2
  exit 2
fi

display="${LEGACY_DISPLAY:-:99}"
startup_delay="${PLANTSTUDIO_LEGACY_STARTUP_DELAY:-4}"
app_dir="/workspace/for-olpc-python"
screenshot_path="${PLANTSTUDIO_LEGACY_SCREENSHOT_PATH:-/tmp/legacy-viewer.png}"
screenshot_dir="$(dirname "$screenshot_path")"
lock_file="/tmp/.X${display#:}-lock"
xvfb_pid=""
viewer_pid=""

cleanup() {
  local pid=""
  for pid in "$viewer_pid" "$xvfb_pid"; do
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
    fi
  done
  rm -f "$lock_file"
}

trap cleanup EXIT

rm -f "$lock_file"

Xvfb "$display" -screen 0 1280x960x24 -nolisten tcp >/tmp/plantstudio-xvfb.log 2>&1 &
xvfb_pid="$!"

sleep 1
export DISPLAY="$display"
export PLANTSTUDIO_PROFILE_PATH="/tmp/plantstudio-hotshot_stats"

cd "$app_dir"
python viewer.py >/tmp/plantstudio-viewer.log 2>&1 &
viewer_pid="$!"

sleep "$startup_delay"

if ! kill -0 "$viewer_pid" 2>/dev/null; then
  wait "$viewer_pid"
fi

case "$mode" in
  smoke)
    echo "Legacy viewer started successfully under $display."
    ;;
  screenshot)
    mkdir -p "$screenshot_dir"
    rm -f "$screenshot_path"
    import -display "$display" -window root "$screenshot_path"
    test -s "$screenshot_path"
    dimensions="$(identify -format '%wx%h' "$screenshot_path")"
    echo "Captured $screenshot_path ($dimensions)."
    ;;
  *)
    echo "unknown mode: $mode" >&2
    exit 2
    ;;
esac
