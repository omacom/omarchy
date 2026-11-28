#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command lua

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
export OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH"

# Exit status, expected MESA_GLES_VERSION_OVERRIDE/MESA_GLSL_VERSION_OVERRIDE, then vendor:device:class.
while IFS='|' read -r description expected_status expected_env devices; do
  rm -rf "$tmp_dir/devices"
  mkdir -p "$tmp_dir/devices"
  slot=0
  for spec in $devices; do
    IFS=: read -r vendor device class <<<"$spec"
    device_dir="$tmp_dir/devices/$slot"
    mkdir -p "$device_dir"
    printf '%s\n' "$vendor" >"$device_dir/vendor"
    printf '%s\n' "$device" >"$device_dir/device"
    printf '%s\n' "$class" >"$device_dir/class"
    slot=$((slot + 1))
  done

  status=0
  omarchy-hw-intel-gles2 || status=$?
  [[ $status == "$expected_status" ]] || fail "$description: omarchy-hw-intel-gles2" "expected $expected_status, got $status"

  # Run the real Lua config and detector; capture only Hyprland's env calls.
  actual_env=$(lua <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path
require("default.hypr.helpers")
local env = {}
hl = { env = function(key, value) env[key] = value end }
require("default.hypr.intel-gles2")
print(table.concat({ env.MESA_GLES_VERSION_OVERRIDE or "-", env.MESA_GLSL_VERSION_OVERRIDE or "-" }, " "))
LUA
  )
  [[ $actual_env == "$expected_env" ]] || fail "$description: GLES environment" "expected $expected_env, got $actual_env"
  pass "$description"
done <<'CASES'
GM45|0|3.0 300|0x8086:0x2a42:0x030000
GM45 with secondary display function|0|3.0 300|0x8086:0x2a42:0x030000 0x8086:0x2a43:0x038000
Ironlake|0|3.0 300|0x8086:0x0046:0x030000
i965|0|3.0 300|0x8086:0x29a2:0x030000
G41|0|3.0 300|0x8086:0x2e32:0x030000
Sandy Bridge|1|- -|0x8086:0x0116:0x030000
Modern Intel|1|- -|0x8086:0x46a6:0x030000
Non-display Intel function reusing a listed ID|1|- -|0x8086:0x2a42:0x060000
AMD only|1|- -|0x1002:0x15e7:0x030000
No PCI devices|1|- -|
Non-Intel vendor with a colliding ID|1|- -|0x10de:0x0042:0x030000
CASES
