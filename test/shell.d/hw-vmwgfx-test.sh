#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

detector="$ROOT/bin/omarchy-hw-vmwgfx"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

# Each argument is a driver and what it has bound, in sysfs's own shape:
# "<driver>" alone is a loaded driver with nothing bound, "<driver>@<slot>" a
# device bound without a display, "<driver>@<slot>@<card>" one with a display.
write_pci_drivers() {
  rm -rf "$tmp_dir/drivers"
  mkdir -p "$tmp_dir/drivers"

  local spec driver slot card rest
  for spec in "$@"; do
    driver=${spec%%@*}
    mkdir -p "$tmp_dir/drivers/$driver"

    rest=${spec#"$driver"}
    rest=${rest#@}
    [[ -n $rest ]] || continue

    slot=${rest%%@*}
    mkdir -p "$tmp_dir/drivers/$driver/$slot"

    card=${rest#"$slot"}
    card=${card#@}
    [[ -n $card ]] || continue

    mkdir -p "$tmp_dir/drivers/$driver/$slot/drm/$card"
  done
}

assert_detects() {
  local description="$1" expected="$2" actual=no
  OMARCHY_PCI_DRIVERS_PATH="$tmp_dir/drivers" "$detector" && actual=yes
  [[ $actual == "$expected" ]] || fail "$description" "expected $expected, got $actual"
  pass "$description"
}

# A VMware guest: vmwgfx bound to the SVGA adapter, which has the display.
write_pci_drivers vmwgfx@0000:00:0f.0@card0
assert_detects "a guest whose display is driven by vmwgfx detects" yes

# A VirtualBox guest on VMSVGA, which emulates that adapter down to its PCI
# IDs and is driven by vmwgfx too, so it has the same quirks.
write_pci_drivers vmwgfx@0000:00:02.0@card0 vboxguest@0000:00:04.0
assert_detects "a VirtualBox guest on VMSVGA detects" yes

# An ordinary laptop.
write_pci_drivers i915@0000:00:02.0@card0
assert_detects "bare metal detects nothing" no

# QEMU's virtio-gpu, a virtual display that vmwgfx has nothing to do with.
write_pci_drivers virtio-pci@0000:00:01.0@card0
assert_detects "a QEMU guest on virtio-gpu detects nothing" no

# The module is loaded but nothing is bound to it, which is what blacklisting
# the driver or removing the adapter leaves behind.
write_pci_drivers vmwgfx i915@0000:00:02.0@card0
assert_detects "a loaded driver with nothing bound detects nothing" no

# Bound, but the device has no display: nothing here applies to it.
write_pci_drivers vmwgfx@0000:00:0f.0
assert_detects "a bound device without a display detects nothing" no

write_pci_drivers
assert_detects "a machine with no PCI drivers detects nothing" no

! grep -v '^[[:space:]]*#' "$detector" | grep -Eq 'lspci|systemd-detect-virt' ||
  fail "the detector reads sysfs rather than probing"
pass "the detector reads sysfs rather than probing"
