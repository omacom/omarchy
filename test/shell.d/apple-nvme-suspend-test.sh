#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

script="$ROOT/install/hardware/apple/fix-suspend-nvme.sh"

finder=$(awk '
  $0 == "find_nvme_pci_device() {" { inside = 1 }
  inside { print }
  inside && $0 == "}" { exit }
' "$script")
[[ -n $finder ]] || fail "Apple NVMe suspend fix exposes a controller discovery helper"
eval "$finder"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
fake_sys="$test_tmp/sys"
mkdir -p "$fake_sys/class/nvme/nvme0" \
  "$fake_sys/bus/pci/devices/0000:02:00.0"
touch "$fake_sys/bus/pci/devices/0000:02:00.0/d3cold_allowed"
ln -s ../../../bus/pci/devices/0000:02:00.0 "$fake_sys/class/nvme/nvme0/device"

[[ $(find_nvme_pci_device "$fake_sys") == 0000:02:00.0 ]] ||
  fail "Apple NVMe suspend fix follows the actual NVMe controller PCI address"
pass "Apple NVMe suspend fix follows the actual NVMe controller PCI address"

rm "$fake_sys/class/nvme/nvme0/device"
mkdir -p "$fake_sys/devices/platform/not-a-pci-device" \
  "$fake_sys/class/nvme/nvme1" \
  "$fake_sys/bus/pci/devices/0000:03:00.0"
ln -s ../../../devices/platform/not-a-pci-device "$fake_sys/class/nvme/nvme0/device"
touch "$fake_sys/bus/pci/devices/0000:03:00.0/d3cold_allowed"
ln -s ../../../bus/pci/devices/0000:03:00.0 "$fake_sys/class/nvme/nvme1/device"

[[ $(find_nvme_pci_device "$fake_sys") == 0000:03:00.0 ]] ||
  fail "Apple NVMe suspend fix rejects non-PCI controller paths"
pass "Apple NVMe suspend fix rejects non-PCI controller paths"

rm "$fake_sys/bus/pci/devices/0000:03:00.0/d3cold_allowed"
if find_nvme_pci_device "$fake_sys" >/dev/null; then
  fail "Apple NVMe suspend fix requires a d3cold_allowed target"
fi
pass "Apple NVMe suspend fix requires a d3cold_allowed target"

grep -Fq 'NVME_PCI=$(find_nvme_pci_device || true)' "$script" ||
  fail "Apple NVMe suspend fix uses discovered controller at install time"
grep -Fq "ExecStart=/bin/bash -c 'echo 0 > \$NVME_DEVICE'" "$script" ||
  fail "Apple NVMe suspend unit targets the discovered controller"
pass "Apple NVMe suspend unit targets the discovered controller"

grep -Fq 'NVME_PCI != "$LEGACY_PCI"' "$script" ||
  fail "Apple NVMe suspend fix only restores a distinct legacy target"
grep -Fq "grep -Fq '0000\\:01\\:00.0/d3cold_allowed' \"\$SERVICE_FILE\"" "$script" ||
  fail "Apple NVMe suspend fix verifies the old Omarchy unit before restoring D3cold"
pass "Apple NVMe suspend fix gates legacy D3cold restoration on the old unit"
