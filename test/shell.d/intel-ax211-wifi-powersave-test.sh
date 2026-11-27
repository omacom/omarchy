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

# Meteor Lake CNVi Wi-Fi (8086:7e40) co-present with a BE200 (8086:272b) scopes
# the override strictly to the AX211 interface, leaving BE200 protected.
mixed_pci="$test_tmp/pci-mixed"
mixed_nm="$test_tmp/nm-mixed"
mkdir -p "$mixed_pci/0000:00:14.3/net/wlp0s20f3" "$mixed_pci/0000:01:00.0/net/wlp1s0"
printf '0x8086\n' >"$mixed_pci/0000:00:14.3/vendor"
printf '0x7e40\n' >"$mixed_pci/0000:00:14.3/device"
printf '0x8086\n' >"$mixed_pci/0000:01:00.0/vendor"
printf '0x272b\n' >"$mixed_pci/0000:01:00.0/device"

run_wifi_leaf "$mixed_pci" "$mixed_nm"
conf="$mixed_nm/zz-intel-ax211-wifi-powersave.conf"
[[ -f $conf ]] || fail "Meteor Lake AX211 writes zz-intel-ax211-wifi-powersave.conf"
grep -qxF 'match-device=interface-name:=wlp0s20f3' "$conf" ||
  fail "AX211 override must match only the 8086:7e40 interface" "$(cat "$conf")"
! grep -qF 'wlp1s0' "$conf" ||
  fail "AX211 override must not include a co-present BE200 interface" "$(cat "$conf")"
pass "Meteor Lake AX211 scopes the override to the 8086:7e40 interface only"

# Intel BE200 (8086:272b) and BE211 (8086:e440) alone must not write the drop-in.
be_pci="$test_tmp/pci-be"
be_nm="$test_tmp/nm-be"
mkdir -p "$be_pci/0000:00:14.3/net/wlp0s20f3" "$be_pci/0000:01:00.0/net/wlp1s0"
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
