#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command lua

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
export OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH"

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
NVIDIA audio only|1|1|1|0|- - -|0x10de:0x228e:0x040300
No PCI devices|1|1|1|0|- - -|
Turing (first GSP)|0|0|1|0|direct nvidia nvidia|0x10de:0x1f91:0x030000
Volta (last without GSP)|0|1|0|0|egl - nvidia|0x10de:0x1d81:0x030000
Maxwell (first 580xx)|0|1|0|0|egl - nvidia|0x10de:0x1340:0x030000
Kepler (unsupported)|0|1|1|0|- - -|0x10de:0x1004:0x030000
AMD display with Ampere offload|0|0|1|1|direct - -|0x1002:0x15bf:0x030000:1 0x10de:0x25ac:0x030200:0
Intel display with Maxwell offload|0|1|0|1|egl - -|0x8086:0x46a6:0x030000:1 0x10de:0x1340:0x030000:0
NVIDIA display with inactive iGPU|0|0|1|0|direct nvidia nvidia|0x1002:0x15bf:0x030000:0 0x10de:0x2c02:0x030000:1
Hybrid without boot_vga|0|0|1|0|direct nvidia nvidia|0x1002:0x15e7:0x030000 0x10de:0x2560:0x030200
CASES
