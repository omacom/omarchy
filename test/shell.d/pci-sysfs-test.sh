#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

source "$ROOT/install/helpers/pci-sysfs.sh"

pci_dir="$test_tmp/pci-devices"

# A GA106 GPU (0x10de:0x2560), its audio function (0x10de:0x228e), and an
# Intel BE200 Wi-Fi card (0x8086:0xe440).
write_pci_devices "$pci_dir" \
  0x10de:0x2560:0x030200 \
  0x10de:0x228e:0x040300 \
  0x8086:0xe440:0x028000

with_pci() {
  OMARCHY_PCI_DEVICES_PATH="$pci_dir" "$@"
}

with_pci omarchy-pci-id 0x10de 0x2560
pass "vendor/device ID matches a present device"

if with_pci omarchy-pci-id 0x18de 0x2560; then
  fail "vendor/device ID requires the vendor to match"
fi
pass "vendor/device ID requires the vendor to match"

with_pci omarchy-pci-id 0x10de 0x228e
pass "vendor/device ID matches a second device for the same vendor"

if with_pci omarchy-pci-id 0x10de 0x1234; then
  fail "vendor/device ID rejects a missing device"
fi
pass "vendor/device ID rejects a missing device"

with_pci omarchy-pci-class-vendor 0x03 0x10de
pass "class prefix 0x03 with the NVIDIA vendor matches the display controller"

with_pci omarchy-pci-class-vendor 0x04 0x10de
pass "class prefix 0x04 with the NVIDIA vendor matches the audio function"

if with_pci omarchy-pci-class-vendor 0x03 0x1002; then
  fail "class prefix with a wrong vendor does not match"
fi
pass "class prefix with a wrong vendor does not match"

if with_pci omarchy-pci-class-vendor 0x03 0x8086; then
  fail "class prefix 0x03 does not match a non-display device"
fi
pass "class prefix 0x03 does not match a non-display device"

[[ $(with_pci omarchy-pci-class-count 0x03) == 1 ]]
pass "class count is 1 with a single display controller"

[[ $(with_pci omarchy-pci-class-count 0x04) == 1 ]]
pass "class count is 1 with a single audio function"

[[ $(with_pci omarchy-pci-class-count 0x99) == 0 ]]
pass "class count is 0 with no matching device"

# A device that is not yet bound to a driver must not satisfy a driver check.
write_pci_devices "$pci_dir" 0x14e4:0x43ba:0x028000
if with_pci omarchy-pci-driver b43; then
  fail "an unbound device is not reported under any driver"
fi
pass "an unbound device is not reported under any driver"

bind_pci_driver "$pci_dir" "0000:00:00.0" b43
with_pci omarchy-pci-driver b43
pass "a bound device is reported under its driver"
