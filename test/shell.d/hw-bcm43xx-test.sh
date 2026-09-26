#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

write_pci() {
  rm -rf "$tmp/devices"
  mkdir -p "$tmp/devices"
  local index=0 spec slot
  for spec in "$@"; do
    slot=$(printf '0000:%02x:00.0' "$index")
    mkdir -p "$tmp/devices/$slot"
    printf '%s\n' "${spec%%:*}" >"$tmp/devices/$slot/vendor"
    printf '%s\n' "$(cut -d: -f2 <<<"$spec")" >"$tmp/devices/$slot/device"
    index=$((index + 1))
  done
}

hw() {
  OMARCHY_PCI_DEVICES_PATH="$tmp/devices" "$ROOT/bin/omarchy-hw-bcm43xx"
}

write_pci 0x14e4:0x43a0
hw || fail "BCM4360 is detected"
pass "BCM4360 is detected from sysfs"

write_pci 0x14e4:0x4331
hw || fail "BCM4331 is detected"
pass "BCM4331 is detected from sysfs"

write_pci 0x14e4:0x43ba
hw && fail "a brcmfmac part is not the wl driver"
pass "newer Broadcom Wi-Fi is left to brcmfmac"

write_pci
hw && fail "empty PCI space is not bcm43xx"
pass "a machine with no PCI devices is not bcm43xx"

grep -Fq 'omarchy-hw-bcm43xx' "$ROOT/install/hardware/fix-bcm43xx.sh" ||
  fail "Broadcom wl install uses omarchy-hw-bcm43xx"
! grep -q lspci "$ROOT/install/hardware/fix-bcm43xx.sh" ||
  fail "Broadcom wl install no longer greps lspci twice"
pass "Broadcom wl install does not parse a full lspci dump"
