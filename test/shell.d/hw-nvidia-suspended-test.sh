#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

# Each argument is "vendor:class:runtime_status"; an empty status omits the file.
write_pci_devices() {
  rm -rf "$tmp_dir/devices"
  mkdir -p "$tmp_dir/devices"

  local index=0 spec
  for spec in "$@"; do
    local slot vendor class status
    slot=$(printf '0000:%02x:00.0' "$index")
    IFS=: read -r vendor class status <<<"$spec"
    mkdir -p "$tmp_dir/devices/$slot/power"
    printf '%s\n' "$vendor" >"$tmp_dir/devices/$slot/vendor"
    printf '%s\n' "$class" >"$tmp_dir/devices/$slot/class"
    [[ -z $status ]] || printf '%s\n' "$status" >"$tmp_dir/devices/$slot/power/runtime_status"
    index=$((index + 1))
  done
}

detects() {
  OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" "$ROOT/bin/omarchy-hw-nvidia-suspended"
}

write_pci_devices "0x1002:0x030000:active" "0x10de:0x030200:suspended"
detects || fail "a runtime-suspended NVIDIA GPU is detected as suspended"
pass "a runtime-suspended NVIDIA GPU is detected as suspended"

write_pci_devices "0x1002:0x030000:active" "0x10de:0x030200:active"
detects && fail "an active NVIDIA GPU is not reported as suspended"
pass "an active NVIDIA GPU is not reported as suspended"

write_pci_devices "0x10de:0x030200:suspended" "0x10de:0x030200:active"
detects && fail "one awake NVIDIA GPU keeps the machine out of the suspended state"
pass "one awake NVIDIA GPU keeps the machine out of the suspended state"

write_pci_devices "0x10de:0x030200:"
detects && fail "an NVIDIA GPU without runtime power management is not reported as suspended"
pass "an NVIDIA GPU without runtime power management is not reported as suspended"

write_pci_devices "0x1002:0x030000:active" "0x10de:0x040300:suspended"
detects && fail "a machine with no NVIDIA display device is not reported as suspended"
pass "a machine with no NVIDIA display device is not reported as suspended"
