#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
export OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" PATH="$ROOT/bin:$PATH"

# Expected exit status, then vendor:device:class for each display controller.
while IFS='|' read -r description expected devices; do
  rm -rf "$tmp_dir/devices"
  mkdir -p "$tmp_dir/devices"
  slot=0
  for spec in $devices; do
    IFS=: read -r vendor device class <<<"$spec"
    mkdir -p "$tmp_dir/devices/$slot"
    printf '%s\n' "$vendor" >"$tmp_dir/devices/$slot/vendor"
    printf '%s\n' "$device" >"$tmp_dir/devices/$slot/device"
    printf '%s\n' "$class" >"$tmp_dir/devices/$slot/class"
    slot=$((slot + 1))
  done

  status=0
  omarchy-hw-intel-no-av1-decode || status=$?
  [[ $status == "$expected" ]] || fail "$description" "expected $expected, got $status"
  pass "$description"
done <<'CASES'
Skylake|0|0x8086:0x1916:0x030000
Kaby Lake|0|0x8086:0x5916:0x030000
Coffee Lake|0|0x8086:0x3e9b:0x030000
Comet Lake|0|0x8086:0x9bca:0x030000
Ice Lake, a 2020 MacBook Air|0|0x8086:0x8a51:0x030000
Apollo Lake|0|0x8086:0x5a85:0x030000
Tiger Lake decodes AV1|1|0x8086:0x9a49:0x030000
Alder Lake decodes AV1|1|0x8086:0x46a6:0x030000
Meteor Lake decodes AV1|1|0x8086:0x7d55:0x030000
Intel Arc decodes AV1|1|0x8086:0x56a0:0x030000
AMD only|1|0x1002:0x15e7:0x030000
NVIDIA only|1|0x10de:0x1f91:0x030000
Ice Lake with an NVIDIA GPU|1|0x8086:0x8a51:0x030000 0x10de:0x25ac:0x030200
Ice Lake with an AMD GPU|1|0x8086:0x8a51:0x030000 0x1002:0x15bf:0x030000
No display controller, only an Intel audio device|1|0x8086:0x8a51:0x040300
No PCI devices|1|
CASES
