#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

looknfeel="$test_tmp/home/.config/hypr/looknfeel.lua"
mkdir -p "$(dirname "$looknfeel")"
printf '%s\n' '-- User look and feel' >"$looknfeel"

run_fix() {
  local driver="${1:-nouveau}"
  local pci_dir="$test_tmp/pci-$driver-$RANDOM"
  # A display controller (class 0x03) with the NVIDIA vendor ID, bound to the
  # driver under test.
  write_pci_devices "$pci_dir" 0x10de:0x1c03:0x030200
  bind_pci_driver "$pci_dir" "0000:00:00.0" "$driver"

  HOME="$test_tmp/home" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_PCI_DEVICES_PATH="$pci_dir" \
    OMARCHY_NVIDIA_MODPROBE_CONFIG="$test_tmp/nvidia.conf" \
    bash -euo pipefail -c 'source "$ROOT/install/user/hardware/fix-nouveau-cursor.sh"'
}

run_fix >/dev/null
grep -F 'no_hardware_cursors = true' "$looknfeel" >/dev/null
pass "nouveau hardware setup enables software cursors"

run_fix >/dev/null
(( $(grep -c 'no_hardware_cursors = true' "$looknfeel") == 1 )) || fail "nouveau cursor setup is idempotent"
pass "nouveau cursor setup is idempotent"

printf '%s\n' '-- User look and feel' >"$looknfeel"
run_fix i915 >/dev/null
if grep -q 'no_hardware_cursors' "$looknfeel"; then
  fail "nouveau cursor setup ignores other video drivers"
fi
pass "nouveau cursor setup ignores other video drivers"

touch "$test_tmp/nvidia.conf"
run_fix >/dev/null
if grep -q 'no_hardware_cursors' "$looknfeel"; then
  fail "nouveau cursor setup skips proprietary NVIDIA installs"
fi
pass "nouveau cursor setup skips proprietary NVIDIA installs"
