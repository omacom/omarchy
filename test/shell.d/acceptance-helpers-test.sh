#!/bin/bash

source "$(dirname "$0")/base-test.sh"
# This host is not a VM; the acceptance helpers refuse it without the override.
export OMARCHY_ACCEPTANCE_ALLOW_HOST=1
source "$ROOT/test/acceptance.d/base-test.sh"

monitor_json='[
  {"name":"DP-1","x":1920,"y":0,"width":3840,"height":2160,"scale":2},
  {"name":"DP-2","x":-2560,"y":-1440,"width":2560,"height":1440,"scale":1},
  {"name":"DP-3","x":0,"y":1080,"width":1920,"height":1080,"scale":1,"transform":1}
]'
layer_json='{
  "DP-1":{"levels":{"2":[
    {"x":0,"y":0,"w":1920,"h":26,"namespace":"visible-positive-offset"},
    {"x":1920,"y":0,"w":26,"h":1080,"namespace":"parked-positive-offset"}
  ]}},
  "DP-2":{"levels":{"2":[
    {"x":0,"y":0,"w":2560,"h":26,"namespace":"visible-negative-offset"},
    {"x":-26,"y":0,"w":26,"h":1440,"namespace":"parked-negative-offset"}
  ]}},
  "DP-3":{"levels":{"2":[
    {"x":0,"y":1500,"w":26,"h":26,"namespace":"visible-rotated"},
    {"x":1080,"y":0,"w":26,"h":1920,"namespace":"parked-rotated"}
  ]}}
}'

hyprctl() {
  if [[ $2 == "monitors" ]]; then
    printf '%s\n' "$monitor_json"
  elif [[ $2 == "layers" ]]; then
    printf '%s\n' "$layer_json"
  elif [[ $2 == "activewindow" ]]; then
    printf '%s\n' "$active_json"
  else
    return 1
  fi
}

assert_layer_on_screen() {
  local namespace="$1" description="$2"

  layer_on_screen "$namespace" && pass "$description" || fail "$description"
}

assert_layer_off_screen() {
  local namespace="$1" description="$2"

  layer_off_screen "$namespace" && pass "$description" || fail "$description"
}

assert_layer_on_screen "visible-positive-offset" "visible layer is found on a positively offset monitor"
assert_layer_off_screen "parked-positive-offset" "right-parked layer stays off a positively offset monitor"
assert_layer_on_screen "visible-negative-offset" "visible layer is found on a negatively offset monitor"
assert_layer_off_screen "parked-negative-offset" "left-parked layer stays off a negatively offset monitor"
assert_layer_on_screen "visible-rotated" "visible layer uses the transformed monitor height"
assert_layer_off_screen "parked-rotated" "parked layer uses the transformed monitor width"

active_json='{"class":"org.omarchy.ime-test"}'
window_focused '^org\.omarchy\.ime-test$' >/dev/null && pass "window_focused matches the focused window's class" || fail "window_focused matches the focused window's class"
active_json='{"class":"signal"}'
! window_focused '^org\.omarchy\.ime-test$' >/dev/null && pass "window_focused rejects another focused window" || fail "window_focused rejects another focused window"
active_json='{}'
! window_focused '^org\.omarchy\.ime-test$' >/dev/null && pass "window_focused rejects no focused window" || fail "window_focused rejects no focused window"

# The host guard: stub systemd-detect-virt so the answer does not depend on
# where this runs, and source or run in a child so its exit cannot end this test.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/runtime"
printf '#!/bin/bash\nexit "$VIRT_STATUS"\n' > "$tmp/bin/systemd-detect-virt"
printf '#!/bin/bash\nexit 1\n' > "$tmp/bin/hyprctl"
chmod +x "$tmp/bin/systemd-detect-virt" "$tmp/bin/hyprctl"

source_helpers() {
  env -u OMARCHY_ACCEPTANCE_ALLOW_HOST PATH="$tmp/bin:$PATH" OMARCHY_ACCEPTANCE_DIR="$tmp/artifacts" "$@" \
    bash -c 'source "$1" && echo sourced' _ "$ROOT/test/acceptance.d/base-test.sh" 2>&1
}

output=$(source_helpers VIRT_STATUS=1) && fail "acceptance helpers refuse a host that is not a VM" "$output"
[[ $output == *"refusing to run outside a virtual machine"*"OMARCHY_ACCEPTANCE_ALLOW_HOST=1"* ]] || fail "acceptance helpers refuse a host that is not a VM" "$output"
pass "acceptance helpers refuse a host that is not a VM"

output=$(source_helpers VIRT_STATUS=1 OMARCHY_ACCEPTANCE_ALLOW_HOST=1) || fail "acceptance helpers load on a host with the override" "$output"
[[ $output == "sourced" ]] || fail "acceptance helpers load on a host with the override" "$output"
pass "acceptance helpers load on a host with the override"

output=$(source_helpers VIRT_STATUS=0) || fail "acceptance helpers load in a VM" "$output"
[[ $output == "sourced" ]] || fail "acceptance helpers load in a VM" "$output"
pass "acceptance helpers load in a VM"

# The runner must refuse before it looks for a session. Should the guard fail,
# the empty runtime dir, zero boot timeout and failing hyprctl stop it at
# "session never came up", so no acceptance file can reach this desktop.
output=$(env -u OMARCHY_ACCEPTANCE_ALLOW_HOST -u HYPRLAND_INSTANCE_SIGNATURE -u WAYLAND_DISPLAY \
  PATH="$tmp/bin:$PATH" VIRT_STATUS=1 OMARCHY_PATH="$tmp" OMARCHY_ACCEPTANCE_DIR="$tmp/artifacts" \
  XDG_RUNTIME_DIR="$tmp/runtime" DISPLAY=:0 LANG=C.UTF-8 OMARCHY_ACCEPTANCE_BOOT_TIMEOUT=0 \
  bash "$ROOT/test/acceptance" 2>&1) && fail "acceptance runner refuses a host that is not a VM" "$output"
[[ $output == *"refusing to run outside a virtual machine"*"OMARCHY_ACCEPTANCE_ALLOW_HOST=1"* ]] || fail "acceptance runner refuses a host that is not a VM" "$output"
pass "acceptance runner refuses a host that is not a VM"
