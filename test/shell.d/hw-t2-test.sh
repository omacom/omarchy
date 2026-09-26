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
    printf '%s\n' "${spec##*:}" >"$tmp/devices/$slot/class"
    index=$((index + 1))
  done
}

hw_t2() {
  OMARCHY_PCI_DEVICES_PATH="$tmp/devices" "$ROOT/bin/omarchy-hw-t2"
}

write_pci 0x106b:0x1801:0x068000
hw_t2 || fail "T2 chip 1801 is detected"
pass "Apple T2 device 1801 is detected from sysfs"

write_pci 0x106b:0x1802:0x068000
hw_t2 || fail "T2 chip 1802 is detected"
pass "Apple T2 device 1802 is detected from sysfs"

write_pci 0x106b:0x1803:0x068000
hw_t2 && fail "a different Apple PCI id is not a T2 chip"
pass "other Apple PCI functions are not treated as T2"

write_pci
hw_t2 && fail "empty PCI space is not T2"
pass "a machine with no PCI devices is not T2"

grep -Fq 'omarchy-hw-t2' "$ROOT/install/hardware/apple/fix-t2.sh" ||
  fail "T2 package install uses omarchy-hw-t2"
grep -Fq 'omarchy-hw-t2' "$ROOT/install/hardware/pacman.sh" ||
  fail "the arch-mact2 repo drop-in uses omarchy-hw-t2"
! grep -q 'lspci' "$ROOT/install/hardware/apple/fix-t2.sh" ||
  fail "T2 package install no longer greps lspci"
! grep -q 'lspci' "$ROOT/install/hardware/pacman.sh" ||
  fail "the arch-mact2 repo drop-in no longer greps lspci"
pass "T2 install paths share one sysfs helper"

# Hold the vendor read after both attributes were checked, then remove the
# device ID before completing the vendor read: deterministic hot-unplug race.
write_pci 0x106b:0x1801:0x068000
rm "$tmp/devices/0000:00:00.0/vendor"
mkfifo "$tmp/devices/0000:00:00.0/vendor"
hw_t2 2>"$tmp/hot-unplug.stderr" &
reader=$!
exec 3>"$tmp/devices/0000:00:00.0/vendor"
rm "$tmp/devices/0000:00:00.0/device"
printf '0x106b\n' >&3
exec 3>&-
if wait "$reader"; then fail "a disappearing device cannot be confirmed as T2"; fi
[[ ! -s $tmp/hot-unplug.stderr ]] || fail "mid-read hot-unplug is handled without a shell error" "$(cat "$tmp/hot-unplug.stderr")"
pass "mid-read hot-unplug does not produce a false match or shell error"
