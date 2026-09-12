#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

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
  OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" "$ROOT/bin/omarchy-hw-amd" && actual=yes

  [[ $actual == "$expected" ]] ||
    fail "$description" "omarchy-hw-amd: expected $expected, got $actual"

  pass "$description"
}

# AMD Navi 31 [Radeon RX 7900 XT], the card from issue #10380.
write_pci_devices 0x1002:0x744c:0x030000
assert_detects "a discrete Radeon is an AMD GPU" yes

# AMD Cezanne integrated graphics.
write_pci_devices 0x1002:0x15e7:0x030000
assert_detects "an integrated Radeon is an AMD GPU" yes

# NVIDIA GA106M [RTX 3060 Mobile] alongside AMD Cezanne.
write_pci_devices 0x1002:0x15e7:0x030000 0x10de:0x2560:0x030200
assert_detects "a hybrid laptop with an AMD iGPU is an AMD GPU" yes

# NVIDIA GP104 [GTX 1080] on its own.
write_pci_devices 0x10de:0x1b80:0x030000
assert_detects "an NVIDIA-only machine is not an AMD GPU" no

# Intel Alder Lake-P integrated graphics.
write_pci_devices 0x8086:0x46a6:0x030000
assert_detects "an Intel-only machine is not an AMD GPU" no

# The Navi 31 HDMI audio function carries the AMD vendor ID but is not a GPU.
write_pci_devices 0x1002:0xab30:0x040300
assert_detects "a non-display AMD function is not a GPU" no

write_pci_devices
assert_detects "a machine with no PCI devices detects nothing" no
