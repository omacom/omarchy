#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

export HOME="$tmp_dir/home"
export OMARCHY_PATH="$ROOT"
export PATH="$ROOT/bin:$PATH"
mkdir -p "$HOME/.config/omarchy"

frame_rate() {
  "$ROOT/bin/omarchy-screensaver-frame-rate" "$@"
}

write_config() {
  printf '%s\n' "$1" >"$HOME/.config/omarchy/shell.json"
}

# Without a user shell.json the shipped default applies, and the default has to
# stay well under the old hardcoded 120: foot rasterizes every frame on the CPU
# at native panel resolution, so 120fps on a 5K panel pinned three cores.
default=$(jq -r '.idle.screensaverFrameRate' "$ROOT/config/omarchy/shell.json")
[[ $default =~ ^[0-9]+$ ]] || fail "default shell.json ships idle.screensaverFrameRate" "$default"
(( default <= 60 )) || fail "default screensaver frame rate is at most 60" "$default"
[[ $(frame_rate) == "$default" ]] || fail "screensaver frame rate falls back to the shipped default" "$(frame_rate)"
pass "screensaver frame rate defaults to $default"

write_config '{"version": 1, "idle": {"screensaver": 150, "lock": 300, "screensaverFrameRate": 30}}'
[[ $(frame_rate) == "30" ]] || fail "screensaver frame rate reads idle.screensaverFrameRate" "$(frame_rate)"
pass "screensaver frame rate reads idle.screensaverFrameRate"

write_config '{"version": 1, "idle": {"screensaver": 150, "lock": 300}}'
[[ $(frame_rate) == "$default" ]] || fail "screensaver frame rate defaults when the key is missing" "$(frame_rate)"
pass "screensaver frame rate defaults when the key is missing"

for bad in '"fast"' '0' '-5' '12.5' 'null'; do
  write_config "{\"version\": 1, \"idle\": {\"screensaverFrameRate\": $bad}}"
  [[ $(frame_rate) == "$default" ]] || fail "screensaver frame rate rejects $bad" "$(frame_rate)"
done
pass "screensaver frame rate rejects invalid values"

write_config 'not json'
[[ $(frame_rate 2>/dev/null) == "$default" ]] || fail "screensaver frame rate survives a broken shell.json" "$(frame_rate 2>/dev/null)"
pass "screensaver frame rate survives a broken shell.json"

# Frames above the panel's refresh rate can never be displayed, so the monitor
# refresh rate caps whatever is configured.
write_config '{"version": 1, "idle": {"screensaverFrameRate": 120}}'
[[ $(frame_rate 60) == "60" ]] || fail "screensaver frame rate is capped to the monitor refresh rate" "$(frame_rate 60)"
[[ $(frame_rate 144) == "120" ]] || fail "screensaver frame rate keeps the configured rate under a faster refresh rate" "$(frame_rate 144)"
[[ $(frame_rate 0) == "120" ]] || fail "screensaver frame rate ignores an unknown refresh rate" "$(frame_rate 0)"
[[ $(frame_rate abc) == "120" ]] || fail "screensaver frame rate ignores a malformed refresh rate" "$(frame_rate abc)"
[[ $(frame_rate 59.997) == "60" ]] || fail "screensaver frame rate rounds a fractional refresh rate" "$(frame_rate 59.997)"
pass "screensaver frame rate is capped to the monitor refresh rate"

# The screensaver itself must take the frame rate from the helper rather than
# hardcoding one, and the launcher must hand each window its monitor's refresh
# rate so the cap applies per monitor.
if rg -q -- '--frame-rate [0-9]' "$ROOT/bin/omarchy-screensaver"; then
  fail "omarchy-screensaver does not hardcode a frame rate"
fi
rg -q 'omarchy-screensaver-frame-rate' "$ROOT/bin/omarchy-screensaver" || fail "omarchy-screensaver uses the frame rate helper"
rg -q 'OMARCHY_SCREENSAVER_MAX_FRAME_RATE' "$ROOT/bin/omarchy-screensaver" || fail "omarchy-screensaver honors the per-monitor refresh rate cap"
rg -q 'OMARCHY_SCREENSAVER_MAX_FRAME_RATE' "$ROOT/bin/omarchy-launch-screensaver" || fail "omarchy-launch-screensaver passes each monitor's refresh rate"
pass "screensaver frame rate is wired through the launcher and screensaver"
