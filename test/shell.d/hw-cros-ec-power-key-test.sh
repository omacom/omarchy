#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command lua

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
export OMARCHY_INPUT_DEVICES_PATH="$tmp_dir/input" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH"

# Exit status, devices Hyprland disables, then name=key-capabilities devices
# separated by ';'. Bitmaps are the kernel's 64-bit sysfs format.
while IFS='|' read -r description expected_status expected_disabled devices; do
  rm -rf "$tmp_dir/input"
  mkdir -p "$tmp_dir/input"
  slot=0
  IFS=';' read -ra specs <<<"$devices"
  for spec in "${specs[@]}"; do
    device_dir="$tmp_dir/input/event$slot/device"
    mkdir -p "$device_dir/capabilities"
    printf '%s\n' "${spec%%=*}" >"$device_dir/name"
    printf '%s\n' "${spec#*=}" >"$device_dir/capabilities/key"
    slot=$((slot + 1))
  done

  status=0
  omarchy-hw-cros-ec-power-key || status=$?
  [[ $status == "$expected_status" ]] || fail "$description: detector" "expected $expected_status, got $status"

  # Run the real Lua config; capture only the devices it disables.
  actual_disabled=$(lua <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path
local disabled = {}
hl = setmetatable({
  device = function(device)
    if device.enabled == false then disabled[#disabled + 1] = device.name end
  end,
}, { __index = function() return function() end end })
require("default.hypr.helpers")
o.window = function() end
require("default.hypr.input")
print(#disabled > 0 and table.concat(disabled, " ") or "-")
LUA
  )
  [[ $actual_disabled == "$expected_disabled" ]] || fail "$description: disabled devices" "expected $expected_disabled, got $actual_disabled"
  pass "$description"
done <<'CASES'
Chromebook EC with power and volume keys|0|power-button|Power Button=8000 10000000000000 0;cros_ec_buttons=1c000000000000 0;Lid Switch=0
Chromebook EC with power key only|0|power-button|cros_ec_buttons=10000000000000 0;Power Button=10000000000000 0
Chromebook EC with volume keys only|1|-|cros_ec_buttons=c000000000000 0;Power Button=10000000000000 0
Regular laptop|1|-|Power Button=10000000000000 0;AT Translated Set 2 keyboard=10000000000000 0
Other device reporting the power key|1|-|Logitech USB Receiver System Control=8000 0 0 0 0 0 0 c000 10000000000000 0
No input devices|1|-|
CASES
