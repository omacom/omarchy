#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command lua

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
export OMARCHY_DRM_CLASS_PATH="$tmp_dir/drm" OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH"

# Exit statuses, expected NVD_BACKEND/LIBVA/GLX values, then vendor:device:class[:boot_vga].
while IFS='|' read -r description nvidia gsp without_gsp display expected_env devices; do
  rm -rf "$tmp_dir/devices"
  mkdir -p "$tmp_dir/devices"
  slot=0
  for spec in $devices; do
    IFS=: read -r vendor device class boot_vga <<<"$spec"
    device_dir="$tmp_dir/devices/$slot"
    mkdir -p "$device_dir"
    printf '%s\n' "$vendor" >"$device_dir/vendor"
    printf '%s\n' "$device" >"$device_dir/device"
    printf '%s\n' "$class" >"$device_dir/class"
    if [[ -n $boot_vga ]]; then
      printf '%s\n' "$boot_vga" >"$device_dir/boot_vga"
    fi
    slot=$((slot + 1))
  done

  for check in "nvidia:$nvidia" "nvidia-gsp:$gsp" "nvidia-without-gsp:$without_gsp" "nvidia-display:$display"; do
    status=0
    "omarchy-hw-${check%:*}" || status=$?
    [[ $status == "${check#*:}" ]] || fail "$description: ${check%:*}" "expected ${check#*:}, got $status"
  done

  # Run the real Lua config and detectors; capture only Hyprland's env calls.
  actual_env=$(lua <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path
require("default.hypr.helpers")
local env = {}
hl = { env = function(key, value) env[key] = value end }
require("default.hypr.nvidia")
print(table.concat({ env.NVD_BACKEND or "-", env.LIBVA_DRIVER_NAME or "-", env.__GLX_VENDOR_LIBRARY_NAME or "-" }, " "))
LUA
  )
  [[ $actual_env == "$expected_env" ]] || fail "$description: driver environment" "expected $expected_env, got $actual_env"
  pass "$description"
done <<'CASES'
AMD only|1|1|1|1|- - -|0x1002:0x15e7:0x030000:1
NVIDIA audio only|1|1|1|1|- - -|0x10de:0x228e:0x040300
No PCI devices|1|1|1|1|- - -|
Turing (first GSP)|0|0|1|0|direct nvidia nvidia|0x10de:0x1f91:0x030000
Volta (last without GSP)|0|1|0|0|egl - nvidia|0x10de:0x1d81:0x030000
Maxwell (first 580xx)|0|1|0|0|egl - nvidia|0x10de:0x1340:0x030000
Kepler (unsupported)|0|1|1|0|- - -|0x10de:0x1004:0x030000
AMD display with Ampere offload|0|0|1|1|- - -|0x1002:0x15bf:0x030000:1 0x10de:0x25ac:0x030200:0
Intel display with Maxwell offload|0|1|0|1|- - -|0x8086:0x46a6:0x030000:1 0x10de:0x1340:0x030000:0
NVIDIA display with inactive iGPU|0|0|1|0|direct nvidia nvidia|0x1002:0x15bf:0x030000:0 0x10de:0x2c02:0x030000:1
Hybrid without boot_vga|0|0|1|0|direct nvidia nvidia|0x1002:0x15e7:0x030000 0x10de:0x2560:0x030200
CASES

write_drm_cards() {
  rm -rf "$tmp_dir/drm"
  mkdir -p "$tmp_dir/drm"
  local spec card vendor connector status
  for spec in "$@"; do
    IFS='|' read -r card vendor connector status <<<"$spec"
    mkdir -p "$tmp_dir/drm/$card/device"
    printf '%s\n' "$vendor" >"$tmp_dir/drm/$card/device/vendor"
    if [[ -n $connector ]]; then
      mkdir -p "$tmp_dir/drm/$card-$connector"
      printf '%s\n' "$status" >"$tmp_dir/drm/$card-$connector/status"
    fi
  done
}

assert_display() {
  local expected=$1 description=$2 status=0 actual_env expected_env="- - -"
  "$ROOT/bin/omarchy-hw-nvidia-display" || status=$?
  [[ $status == "$expected" ]] || fail "$description" "expected exit $expected, got $status"
  if ((expected == 0)); then expected_env="direct nvidia nvidia"; fi
  actual_env=$(lua <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path
require("default.hypr.helpers")
local env = {}
hl = { env = function(key, value) env[key] = value end }
require("default.hypr.nvidia")
print(table.concat({ env.NVD_BACKEND or "-", env.LIBVA_DRIVER_NAME or "-", env.__GLX_VENDOR_LIBRARY_NAME or "-" }, " "))
LUA
  )
  [[ $actual_env == "$expected_env" ]] || fail "$description: session env" "expected $expected_env, got $actual_env"
  pass "$description"
}

write_drm_cards 'card0|0x10de|HDMI-A-1|disconnected' 'card1|0x8086|eDP-1|connected'
assert_display 1 "an undocked iGPU laptop exports no NVIDIA driver hints"
write_drm_cards 'card0|0x10de|HDMI-A-1|connected' 'card1|0x1002|eDP-1|connected'
assert_display 1 "docking leaves a foreign-panel laptop on the iGPU"
write_drm_cards 'card0|0x10de|DP-3|connected' 'card1|0x8086|eDP-1|disconnected'
assert_display 1 "closing the docked lid does not switch the session to NVIDIA"
write_drm_cards 'card0|0x10de|eDP-1|disconnected' 'card1|0x1002|eDP-2|connected'
assert_display 1 "a G14 iGPU panel works without a boot_vga attribute"
write_drm_cards 'card0|0x10de|eDP-1|connected' 'card1|0x8086|eDP-1|disconnected'
assert_display 0 "a connected NVIDIA panel selects NVIDIA in a discrete display mode"
write_drm_cards 'card0|0x10de|DP-1|connected' 'card1|0x8086|DP-1|disconnected'
assert_display 0 "an unused desktop iGPU does not override the NVIDIA output"
printf '1\n' >"$tmp_dir/devices/0/boot_vga"
assert_display 0 "a desktop NVIDIA output takes priority over an unrelated iGPU boot_vga"
rm "$tmp_dir/devices/0/boot_vga"
write_drm_cards 'card0|0x10de|DP-1|connected' 'card1|0x8086|DP-2|connected'
assert_display 0 "a desktop with monitors on both cards retains NVIDIA selection"
write_drm_cards 'card0|0x10de||'
assert_display 0 "an NVIDIA-only desktop retains driver hints without a detected monitor"
write_drm_cards 'card0|0x10de|DP-1|disconnected'
assert_display 0 "an NVIDIA-only desktop works with a monitor off or behind a KVM"
write_drm_cards 'card0|0x8086|eDP-1|connected'
assert_display 1 "a DRM tree without NVIDIA does not select NVIDIA"

mkdir -p "$tmp_dir/drm-alt"
mv "$tmp_dir/drm" "$tmp_dir/drm-alt/tree"
export OMARCHY_DRM_CLASS_PATH="$tmp_dir/drm-alt/tree"
assert_display 1 "a dash in the sysfs parent path does not hide its cards"
