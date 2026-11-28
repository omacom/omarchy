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
# the override strictly to the AX211 wireless interface, leaving BE200 protected.
mixed_pci="$test_tmp/pci-mixed"
mixed_nm="$test_tmp/nm-mixed"
mkdir -p "$mixed_pci/0000:00:14.3/net/wlp0s20f3/wireless" "$mixed_pci/0000:01:00.0/net/wlp1s0/wireless"
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

# Early first-boot provisioning before net/* exists falls back to driver:iwlwifi
# when no BE200/BE201/BE211 adapter is present, but skips if BE200 is co-present.
early_pci="$test_tmp/pci-early"
early_nm="$test_tmp/nm-early"
mkdir -p "$early_pci/0000:00:14.3"
printf '0x8086\n' >"$early_pci/0000:00:14.3/vendor"
printf '0x7e40\n' >"$early_pci/0000:00:14.3/device"

run_wifi_leaf "$early_pci" "$early_nm"
grep -qxF 'match-device=driver:iwlwifi' "$early_nm/zz-intel-ax211-wifi-powersave.conf" ||
  fail "early boot without net/* falls back to driver:iwlwifi when no BE card is present"
pass "early boot without net/* falls back to driver:iwlwifi safely"

early_be_pci="$test_tmp/pci-early-be"
early_be_nm="$test_tmp/nm-early-be"
mkdir -p "$early_be_pci/0000:00:14.3" "$early_be_pci/0000:01:00.0"
printf '0x8086\n' >"$early_be_pci/0000:00:14.3/vendor"
printf '0x7e40\n' >"$early_be_pci/0000:00:14.3/device"
printf '0x8086\n' >"$early_be_pci/0000:01:00.0/vendor"
printf '0x272b\n' >"$early_be_pci/0000:01:00.0/device"

run_wifi_leaf "$early_be_pci" "$early_be_nm"
[[ ! -e $early_be_nm/zz-intel-ax211-wifi-powersave.conf ]] ||
  fail "early boot with co-present BE200 must not fall back to driver:iwlwifi"
pass "early boot with co-present BE200 skips driver:iwlwifi fallback"
