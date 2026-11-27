#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

run_wifi_leaf() {
  local pci_dir=$1 nm_dir=$2
  PATH="$ROOT/bin:$PATH" \
    OMARCHY_PCI_DEVICES_PATH="$pci_dir" \
    OMARCHY_INTEL_AX211_NM_CONF_DIR="$nm_dir" \
    bash -eE -c 'source "$1"' bash "$ROOT/install/hardware/intel/fix-ax211-wifi-powersave.sh"
}

# Meteor Lake CNVi Wi-Fi (8086:7e40) writes the override drop-in.
mtl_pci="$test_tmp/pci-mtl"
mtl_nm="$test_tmp/nm-mtl"
mkdir -p "$mtl_pci/0000:00:14.3"
printf '0x8086\n' >"$mtl_pci/0000:00:14.3/vendor"
printf '0x7e40\n' >"$mtl_pci/0000:00:14.3/device"

run_wifi_leaf "$mtl_pci" "$mtl_nm"
grep -qxF 'wifi.powersave = 3' "$mtl_nm/zz-intel-ax211-wifi-powersave.conf" ||
  fail "Meteor Lake AX211 (8086:7e40) enables wifi.powersave = 3"
pass "Meteor Lake AX211 writes zz-intel-ax211-wifi-powersave.conf"

# Intel BE200 (8086:272b) and BE211 (8086:e440) must NOT receive the override.
be_pci="$test_tmp/pci-be"
be_nm="$test_tmp/nm-be"
mkdir -p "$be_pci/0000:00:14.3" "$be_pci/0000:01:00.0"
printf '0x8086\n' >"$be_pci/0000:00:14.3/vendor"
printf '0xe440\n' >"$be_pci/0000:00:14.3/device"
printf '0x8086\n' >"$be_pci/0000:01:00.0/vendor"
printf '0x272b\n' >"$be_pci/0000:01:00.0/device"

run_wifi_leaf "$be_pci" "$be_nm"
[[ ! -e $be_nm/zz-intel-ax211-wifi-powersave.conf ]] ||
  fail "BE200/BE211 cards must not receive the AX211 power save override"
pass "Intel BE200/BE211 cards are skipped"

# Verify x86 platform gating via hardware/intel/* in logging.sh.
platform=$(bash -c '
  source "$1"
  out=""
  omarchy_leaf_platform "hardware/intel/fix-ax211-wifi-powersave.sh" out
  printf "%s\n" "$out"
' bash "$ROOT/install/helpers/logging.sh")
[[ $platform == "x86" ]] || fail "fix-ax211-wifi-powersave.sh must be classified as x86 (got $platform)"
pass "fix-ax211-wifi-powersave.sh is platform-gated as x86"
