#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command lua

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

# Each argument is a DRM entry as "name:driver", e.g. "card1:nvidia". The
# card's device/driver link points at a directory named after the driver, which
# is all the detector reads. Connector entries ("card1-DP-1") get no driver.
write_drm() {
  rm -rf "$tmp_dir/drm" "$tmp_dir/drivers"
  mkdir -p "$tmp_dir/drm" "$tmp_dir/drivers"

  local spec
  for spec in "$@"; do
    local name=${spec%%:*} driver=${spec#*:}
    mkdir -p "$tmp_dir/drm/$name/device"
    if [[ $driver != "$name" ]]; then
      mkdir -p "$tmp_dir/drivers/$driver"
      ln -s "$tmp_dir/drivers/$driver" "$tmp_dir/drm/$name/device/driver"
    fi
  done
}

hw_nvidia_drm_card() {
  OMARCHY_DRM_CLASS_PATH="$tmp_dir/drm" "$ROOT/bin/omarchy-hw-nvidia-drm-card"
}

# Pinning prints the card and exits 0; anything else prints nothing and exits 1.
assert_card() {
  local description="$1" expected="$2" actual="" status=0 expected_status=1
  actual=$(hw_nvidia_drm_card) || status=$?
  [[ -n $expected ]] && expected_status=0
  [[ $actual == "$expected" ]] || fail "$description" "expected: '$expected', actual: '$actual'"
  (( status == expected_status )) || fail "$description" "expected exit $expected_status, got $status"
  pass "$description"
}

write_drm card0:simple-framebuffer card1:nvidia card1-DP-1 card1-eDP-1
assert_card "NVIDIA beside simpledrm is pinned, connectors are ignored" /dev/dri/card1

write_drm card0:nvidia card0-HDMI-A-1 card1:efi-framebuffer
assert_card "any firmware framebuffer driver counts" /dev/dri/card0

write_drm card0:nvidia card0-DP-1
assert_card "NVIDIA alone keeps autodetection" ""

write_drm card0:simple-framebuffer card1:amdgpu card2:nvidia card2-DP-1
assert_card "a hybrid machine keeps autodetection" ""

write_drm card0:simple-framebuffer card1:nvidia card1-DP-1 card2:nvidia card2-DP-2
assert_card "two NVIDIA cards keep autodetection" ""

write_drm card0:simple-framebuffer card1:nvidia
assert_card "NVIDIA without connectors (modeset=0) keeps autodetection" ""

write_drm card0:amdgpu card1:nvidia card1-DP-1
assert_card "a hybrid machine without a firmware framebuffer keeps autodetection" ""

write_drm card0:simple-framebuffer card1:i915
assert_card "no NVIDIA card keeps autodetection" ""

write_drm
assert_card "no DRM cards at all keeps autodetection" ""

# The session and greeter configs, run for real against the fake DRM tree and a
# fake NVIDIA PCI device; only Hyprland's AQ_DRM_DEVICES call is captured.
unset AQ_DRM_DEVICES
mkdir -p "$tmp_dir/pci/0"
printf '0x10de\n' >"$tmp_dir/pci/0/vendor"
printf '0x1f91\n' >"$tmp_dir/pci/0/device"
printf '0x030000\n' >"$tmp_dir/pci/0/class"

lua_pin() {
  OMARCHY_DRM_CLASS_PATH="$tmp_dir/drm" OMARCHY_PCI_DEVICES_PATH="$tmp_dir/pci" OMARCHY_PATH="$ROOT" lua - "$1" <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path
local env = {}
hl = { env = function(key, value) env[key] = value end, config = function() end }
if arg[1] == "session" then
  require("default.hypr.helpers")
  require("default.hypr.nvidia")
else
  dofile(os.getenv("ROOT") .. "/default/sddm/hyprland.lua")
end
print(env.AQ_DRM_DEVICES or "-")
LUA
}

assert_lua_pin() {
  local description="$1" expected="$2" config actual
  for config in session greeter; do
    actual=$(lua_pin "$config")
    [[ $actual == "$expected" ]] || fail "$config: $description" "expected: '$expected', actual: '$actual'"
  done
  pass "session and greeter: $description"
}

write_drm card0:simple-framebuffer card1:nvidia card1-DP-1
assert_lua_pin "NVIDIA beside simpledrm pins AQ_DRM_DEVICES" /dev/dri/card1
AQ_DRM_DEVICES=/dev/dri/card0 assert_lua_pin "a user-set AQ_DRM_DEVICES is left alone" -

write_drm card0:nvidia card0-DP-1
assert_lua_pin "NVIDIA alone sets nothing" -
