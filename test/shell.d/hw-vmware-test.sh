#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

detector="$ROOT/bin/omarchy-hw-vmware"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

# Each argument is a PCI device as "vendor:device:class", in sysfs's own format.
write_pci_devices() {
  rm -rf "$tmp_dir/devices"
  mkdir -p "$tmp_dir/devices"

  local index=0
  local spec
  for spec in "$@"; do
    local slot
    slot=$(printf '0000:%02x:00.0' "$index")
    mkdir -p "$tmp_dir/devices/$slot"
    printf '%s\n' "${spec%%:*}" >"$tmp_dir/devices/$slot/vendor"
    printf '%s\n' "$(cut -d: -f2 <<<"$spec")" >"$tmp_dir/devices/$slot/device"
    printf '%s\n' "${spec##*:}" >"$tmp_dir/devices/$slot/class"
    index=$((index + 1))
  done
}

assert_detects() {
  local description="$1" expected="$2"

  local actual=no
  OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" "$detector" && actual=yes

  [[ $actual == "$expected" ]] ||
    fail "$description" "omarchy-hw-vmware: expected $expected, got $actual"
  pass "$description"
}

# VMware SVGA II adapter alongside the vmxnet3 NIC and the PVSCSI controller,
# the set a VMware Workstation guest boots with.
write_pci_devices 0x15ad:0x0405:0x030000 0x15ad:0x07b0:0x020000 0x15ad:0x07c0:0x010700
assert_detects "a VMware Workstation guest detects" yes

# VMware SVGA3 adapter, the newer virtual GPU on ESXi and Fusion.
write_pci_devices 0x15ad:0x0406:0x030000
assert_detects "the SVGA3 adapter detects" yes

# vmxnet3 NIC and the VMCI bus carry the VMware vendor ID but are not the GPU.
write_pci_devices 0x15ad:0x07b0:0x020000 0x15ad:0x0740:0x088000
assert_detects "VMware non-display functions alone do not detect" no

# AMD Cezanne integrated graphics.
write_pci_devices 0x1002:0x15e7:0x030000
assert_detects "an AMD laptop does not detect" no

# VirtualBox VGA adapter.
write_pci_devices 0x80ee:0xbeef:0x030000
assert_detects "a VirtualBox guest does not detect" no

# QEMU virtio-gpu.
write_pci_devices 0x1af4:0x1050:0x030000
assert_detects "a QEMU guest does not detect" no

write_pci_devices
assert_detects "a machine with no PCI devices does not detect" no
