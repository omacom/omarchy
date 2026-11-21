#!/bin/bash

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  echo "source test/acceptance.d/base-test.sh from an acceptance test; do not run it directly" >&2
  exit 1
fi

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
ARTIFACTS="${OMARCHY_ACCEPTANCE_DIR:-/tmp/omarchy-acceptance}"

mkdir -p "$ARTIFACTS"

pass() {
  printf 'ok - %s\n' "$1"
}

fail() {
  local description="$1"
  local detail="${2:-}"
  local step=${description,,}

  step=${step// /-}
  step=${step//[^a-z0-9-]/}

  [[ -n $detail ]] && printf '%s\n' "$detail" >&2
  screenshot "failure-$step" || true
  printf 'not ok - %s\n' "$description" >&2
  exit 1
}

screenshot() {
  local snapshot="$ARTIFACTS/$1.png" status
  if timeout 10 grim "$snapshot" 2>/dev/null; then
    return 0
  else
    status=$?
    rm -f "$snapshot"
    printf 'could not capture screenshot %s (grim exit %s)\n' "$snapshot" "$status" >&2
    return "$status"
  fi
}

screen_contains() {
  local text="$1"
  local snapshot="/tmp/omarchy-acceptance-ocr-$$.png"

  # Capture at 2x scale: tesseract routinely drops small caption text at
  # native resolution (the weather panel's detail labels, for one).
  if timeout 10 grim -s 2 "$snapshot" 2>/dev/null; then
    :
  else
    local status=$?
    rm -f "$snapshot"
    printf 'screen capture failed (grim exit %s); OCR was not run\n' "$status" >&2
    return 2
  fi
  tesseract "$snapshot" stdout --psm 11 2>/dev/null | grep -Fi -- "$text" >/dev/null
  local status=$?
  rm -f "$snapshot"
  return $status
}

# Poll a command until it succeeds; screenshot and fail on timeout.
wait_until() {
  local description="$1" timeout="$2"
  shift 2

  local deadline=$((SECONDS + timeout))
  local attempt_log status output
  attempt_log=$(mktemp "$ARTIFACTS/wait.XXXXXX.log") || fail "$description" "could not create polling log"

  until "$@" >"$attempt_log" 2>&1; do
    status=$?
    if ((SECONDS >= deadline)); then
      output=$(<"$attempt_log")
      rm -f "$attempt_log"
      fail "$description" "timed out after ${timeout}s waiting for: $* (last exit $status)${output:+$'\n'$output}"
    fi
    sleep 1
  done

  rm -f "$attempt_log"
  pass "$description"
}

window_present() {
  hyprctl -j clients | jq -e --arg class "$1" '[.[] | select(.class | test($class))] | length > 0'
}

window_absent() {
  ! window_present "$1"
}

layer_present() {
  hyprctl -j layers | jq -e --arg ns "$1" '[.. | objects | select(.namespace? == $ns)] | length > 0'
}

layer_absent() {
  ! layer_present "$1"
}

# Fullscreen overlays map on the overlay layer and unmap when closed.
layer_on_overlay() {
  hyprctl -j layers | jq -e --arg ns "$1" '[.[].levels["3"][]? | select(.namespace == $ns)] | length > 0'
}

# A layer can be mapped but parked off the monitor: the bar hides that way so
# revealing it does not have to rebuild the surface. Assert on geometry when
# what matters is that the user can actually see it. Layer boxes are local to
# their monitor and in logical coordinates, so compare them with local bounds
# derived from the monitor's scaled pixel size.
layer_on_screen() {
  local monitors
  monitors=$(hyprctl -j monitors) || return 1

  hyprctl -j layers | jq -e --arg ns "$1" --argjson monitors "$monitors" '
    to_entries[]
    | .key as $name
    | .value as $levels
    | ($monitors[] | select(.name == $name)) as $m
    | (if ($m.transform // 0) % 2 == 1 then $m.height else $m.width end) / $m.scale | round as $width
    | (if ($m.transform // 0) % 2 == 1 then $m.width else $m.height end) / $m.scale | round as $height
    | [$levels | .. | objects | select(.namespace? == $ns)][]
    | select(
        .x + .w > 0 and .x < $width and
        .y + .h > 0 and .y < $height
      )
  ' >/dev/null
}

layer_off_screen() {
  ! layer_on_screen "$1"
}

# Close every window matching a class regex, by address so multi-window apps
# are fully closed. Tries the quattro Lua dispatcher first, then classic.
close_windows() {
  local class="$1"
  local addr

  while read -r addr; do
    hyprctl dispatch "hl.dsp.window.close({ window = \"address:$addr\" })" >/dev/null 2>&1 ||
      hyprctl dispatch closewindow "address:$addr" >/dev/null 2>&1 || true
  done < <(hyprctl -j clients | jq -r --arg class "$class" '.[] | select(.class | test($class)) | .address')
}

launch_app() {
  setsid -f bash -c "$1" >/dev/null 2>&1
}
