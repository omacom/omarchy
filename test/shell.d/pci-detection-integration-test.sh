#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
export OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices"
export PCI_PACKAGE_LOG="$tmp_dir/packages" PCI_LSPCI_LOG="$tmp_dir/lspci"
mkdir -p "$tmp_dir/bin"
: > "$PCI_LSPCI_LOG"
cat > "$tmp_dir/bin/omarchy-pkg-add" <<'STUB'
#!/bin/bash
printf '%s\n' "$@" >> "$PCI_PACKAGE_LOG"
[[ ${PCI_FAIL_PACKAGES:-0} == 0 ]]
STUB
cat > "$tmp_dir/bin/lspci" <<'STUB'
#!/bin/bash
printf 'unexpected lspci\n' >> "$PCI_LSPCI_LOG"
exit 91
STUB
chmod +x "$tmp_dir/bin/"*
export PATH="$tmp_dir/bin:$ROOT/bin:$PATH"

reset_devices() {
  rm -rf "$OMARCHY_PCI_DEVICES_PATH"
  mkdir -p "$OMARCHY_PCI_DEVICES_PATH"
  : > "$PCI_PACKAGE_LOG"
}

pci_device() {
  local slot="$1" vendor="$2" device="$3" class="$4"
  mkdir -p "$OMARCHY_PCI_DEVICES_PATH/$slot"
  printf '%s\n' "$vendor" > "$OMARCHY_PCI_DEVICES_PATH/$slot/vendor"
  printf '%s\n' "$device" > "$OMARCHY_PCI_DEVICES_PATH/$slot/device"
  printf '%s\n' "$class" > "$OMARCHY_PCI_DEVICES_PATH/$slot/class"
}

assert_detected() {
  local helper="$1" expected="$2" description="$3" actual=1
  if "$ROOT/bin/$helper"; then actual=0; fi
  [[ $actual == "$expected" ]] || fail "$description"
  pass "$description"
}

reset_devices
assert_detected omarchy-hw-bcm43xx 1 "empty sysfs has no wl device"
assert_detected omarchy-hw-t2 1 "empty sysfs has no T2 device"
bash -euo pipefail "$ROOT/install/hardware/vulkan.sh"
[[ ! -s $PCI_PACKAGE_LOG ]] || fail "empty sysfs installs no Vulkan packages"
pass "empty sysfs installs no Vulkan packages"

# IDs have meaning only under the matching vendor.
pci_device 0000:01:00.0 0x8086 0x43a0 0x028000
pci_device 0000:02:00.0 0x8086 0x1801 0x068000
assert_detected omarchy-hw-bcm43xx 1 "matching Broadcom device ID under another vendor is rejected"
assert_detected omarchy-hw-t2 1 "matching T2 device ID under another vendor is rejected"

reset_devices
mkdir -p "$OMARCHY_PCI_DEVICES_PATH/0000:00:00.0"
ln -s "$tmp_dir/gone" "$OMARCHY_PCI_DEVICES_PATH/0000:00:01.0"
pci_device 0000:02:00.0 0x14e4 0x4331 0x028000
pci_device 0000:03:00.0 0x106b 0x1802 0x068000
assert_detected omarchy-hw-bcm43xx 0 "incomplete and removed entries do not hide a later wl match"
assert_detected omarchy-hw-t2 0 "incomplete and removed entries do not hide a later T2 match"
bash -euo pipefail "$ROOT/install/hardware/vulkan.sh"
[[ ! -s $PCI_PACKAGE_LOG ]] || fail "non-display Broadcom and Apple devices install no Vulkan packages"
pass "incomplete and non-display devices install no Vulkan packages"

reset_devices
pci_device 0000:01:00.0 0x14e4 0x43ba 0x028000
assert_detected omarchy-hw-bcm43xx 1 "BCM43602 remains on brcmfmac"

reset_devices
pci_device 0000:00:02.0 0x8086 0x191b 0x030000
pci_device 0000:01:00.0 0x1002 0x67ef 0x030000
pci_device 0000:02:00.0 0x8086 0x1234 0x030200
pci_device 0000:03:00.0 0x10de 0x1234 0x030200
bash -euo pipefail "$ROOT/install/hardware/vulkan.sh"
[[ $(cat "$PCI_PACKAGE_LOG") == $'vulkan-intel\nvulkan-radeon' ]] || fail "hybrid GPUs request each matching non-NVIDIA package once"
pass "hybrid GPUs request each matching non-NVIDIA package once"
assert_detected omarchy-hw-nvidia 0 "the existing NVIDIA helper recognizes a 3D-class GPU"

reset_devices
pci_device 0000:01:00.0 0x10de 0x1234 0x040300
assert_detected omarchy-hw-nvidia 1 "an NVIDIA audio function alone is not an NVIDIA GPU"
bash -euo pipefail "$ROOT/install/hardware/vulkan.sh"
[[ ! -s $PCI_PACKAGE_LOG ]] || fail "NVIDIA audio installs no Vulkan packages"
pass "NVIDIA audio installs no Vulkan packages"

# Preserve shared helper behavior without widening this PR's enablement scope.
reset_devices
pci_device 0000:01:00.0 0x106b 0x1234 0x030000
bash -euo pipefail "$ROOT/install/hardware/vulkan.sh"
[[ $(cat "$PCI_PACKAGE_LOG") == vulkan-asahi ]] || fail "existing Apple display-vendor package mapping is preserved"
pass "existing Apple display-vendor package mapping is preserved"

reset_devices
pci_device 0000:01:00.0 0x8086 0x1234 0x030000
if PCI_FAIL_PACKAGES=1 bash -euo pipefail "$ROOT/install/hardware/vulkan.sh"; then
  fail "a package installation failure must propagate under installer errexit"
fi
pass "Vulkan package failure propagates under installer errexit"
[[ ! -s $PCI_LSPCI_LOG ]] || fail "cached detection paths must not call lspci"
pass "cached detection paths do not call lspci in the exercised fixtures"
