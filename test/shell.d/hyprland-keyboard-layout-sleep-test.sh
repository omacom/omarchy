#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

helper="$ROOT/bin/omarchy-hyprland-keyboard-layout"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
state_dir="$tmpdir/state"
mkdir -p "$mock_bin" "$state_dir"
calls="$tmpdir/calls"
devices_file="$tmpdir/devices.json"
: >"$calls"

cat >"$devices_file" <<'JSON'
{
  "keyboards": [
    {"name": "power-button", "active_layout_index": 0, "main": true},
    {"name": "at-translated-set-2-keyboard", "active_layout_index": 1, "main": false},
    {"name": "hl-virtual-keyboard", "active_layout_index": 0, "main": false}
  ]
}
JSON

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash

printf 'hyprctl' >>"$CALLS"
printf '\t%s' "$@" >>"$CALLS"
printf '\n' >>"$CALLS"

if [[ $1 == devices && $2 == -j ]]; then
  cat "$DEVICES_FILE"
  exit 0
fi
exit 0
SH
chmod +x "$mock_bin/hyprctl"

CALLS="$calls" DEVICES_FILE="$devices_file" PATH="$mock_bin:$PATH" \
  OMARCHY_KEYBOARD_LAYOUT_STATE_DIR="$state_dir" \
  "$helper" save

[[ -f $state_dir/keyboard-layout.state ]] ||
  fail "save writes a state file"
state=$(<"$state_dir/keyboard-layout.state")
[[ $state == $'at-translated-set-2-keyboard\t1' ]] ||
  fail "save picks the furthest-advanced typed keyboard" "state: $state"
pass "save picks the furthest-advanced typed keyboard"

: >"$calls"
CALLS="$calls" DEVICES_FILE="$devices_file" PATH="$mock_bin:$PATH" \
  OMARCHY_KEYBOARD_LAYOUT_STATE_DIR="$state_dir" \
  "$helper" restore

grep -F $'hyprctl\tswitchxkblayout\tat-translated-set-2-keyboard\t1' "$calls" >/dev/null ||
  fail "restore reapplies the saved device layout" "$(cat "$calls")"
pass "restore reapplies the saved device layout"

[[ ! -e $state_dir/keyboard-layout.state ]] ||
  fail "restore consumes the keyboard layout receipt"
pass "restore consumes the keyboard layout receipt"

# A failed new save must clear a stale prior-cycle receipt.
printf 'stale-keyboard\t7\n' >"$state_dir/keyboard-layout.state"
cat >"$devices_file" <<'JSON'
{"keyboards":[{"name":"power-button","active_layout_index":0}]}
JSON
CALLS="$calls" DEVICES_FILE="$devices_file" PATH="$mock_bin:$PATH" \
  OMARCHY_KEYBOARD_LAYOUT_STATE_DIR="$state_dir" "$helper" save
[[ ! -e $state_dir/keyboard-layout.state ]] ||
  fail "failed new save leaves a stale layout receipt"
pass "failed new save cannot resurrect a prior layout"

# Restore the normal fixture for the fallback check below.
cat >"$devices_file" <<'JSON'
{"keyboards":[{"name":"at-translated-set-2-keyboard","active_layout_index":1}]}
JSON
CALLS="$calls" DEVICES_FILE="$devices_file" PATH="$mock_bin:$PATH" \
  OMARCHY_KEYBOARD_LAYOUT_STATE_DIR="$state_dir" "$helper" save

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash

printf 'hyprctl' >>"$CALLS"
printf '\t%s' "$@" >>"$CALLS"
printf '\n' >>"$CALLS"

if [[ $1 == switchxkblayout && $2 != all ]]; then
  exit 1
fi
exit 0
SH
chmod +x "$mock_bin/hyprctl"

: >"$calls"
CALLS="$calls" PATH="$mock_bin:$PATH" \
  OMARCHY_KEYBOARD_LAYOUT_STATE_DIR="$state_dir" \
  "$helper" restore

grep -F $'hyprctl\tswitchxkblayout\tall\t1' "$calls" >/dev/null ||
  fail "restore falls back to all when the device is gone" "$(cat "$calls")"
pass "restore falls back to all when the device is gone"

rm -f "$state_dir/keyboard-layout.state"
: >"$calls"
CALLS="$calls" PATH="$mock_bin:$PATH" \
  OMARCHY_KEYBOARD_LAYOUT_STATE_DIR="$state_dir" \
  "$helper" restore
[[ ! -s $calls ]] || fail "restore without state is a no-op" "$(cat "$calls")"
pass "restore without state is a no-op"
