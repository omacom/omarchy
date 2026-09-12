#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

vulkan="$ROOT/install/hardware/vulkan.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# lspci only has to name the vendor on a VGA line; the driver question is
# answered from sysfs, which is what this script actually gates on.
cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash
echo "01:00.0 VGA compatible controller: ${STUB_GPU_VENDOR:-Advanced Micro Devices, Inc. [AMD/ATI]} RV610"
SH
chmod +x "$stub_bin/lspci"

# A GPU claimed by $1 ("radeon" or "amdgpu"), shaped like /sys/bus/pci/devices.
make_pci_tree() {
  local driver=$1
  local vendor=${2:-0x1002}
  local tree="$test_tmp/pci-$driver-$RANDOM"

  mkdir -p "$tree/0000:01:00.0" "$tree/drivers/$driver"
  echo "$vendor" >"$tree/0000:01:00.0/vendor"
  echo "0x030000" >"$tree/0000:01:00.0/class"
  ln -s "../drivers/$driver" "$tree/0000:01:00.0/driver"

  echo "$tree"
}

# Sourcing vulkan.sh with omarchy-pkg-add stubbed records what it would install.
# The packages go to a file rather than stdout: the script also explains itself
# on stdout, and those messages name the very packages being asserted on.
installed_packages() {
  local pci_path=$1
  local calls="$test_tmp/calls-$RANDOM"

  # "$BASH", not "bash": vulkan.sh needs an associative array, and a stray
  # bash 3.2 earlier in PATH would silently drop the AMD entry instead.
  PATH="$stub_bin:$PATH" \
  OMARCHY_PCI_DEVICES_PATH="$pci_path" \
  OMARCHY_TEST_CALLS="$calls" \
    "$BASH" -c '
      omarchy-pkg-add() { printf "%s\n" "$@" >>"$OMARCHY_TEST_CALLS"; }
      source "$1"
    ' _ "$vulkan" >/dev/null 2>&1

  [[ -f $calls ]] && cat "$calls" || true
}

# Pre-GCN: radeon-driven AMD GPUs cannot be used by RADV, and the ICD that
# vulkan-radeon drops in would otherwise make omarchy-hw-vulkan answer yes.
pre_gcn=$(make_pci_tree radeon)
result=$(installed_packages "$pre_gcn")
[[ $result != *vulkan-radeon* ]] ||
  fail "vulkan-radeon is skipped on a pre-GCN AMD GPU bound to radeon (got: $result)"
pass "pre-GCN AMD GPUs on the radeon driver do not get vulkan-radeon"

# GCN and newer still must, or every supported AMD machine loses Vulkan.
gcn=$(make_pci_tree amdgpu)
result=$(installed_packages "$gcn")
[[ $result == *vulkan-radeon* ]] ||
  fail "vulkan-radeon is still installed for an amdgpu-bound GPU (got: $result)"
pass "AMD GPUs on the amdgpu driver still get vulkan-radeon"

# A GPU with no bound driver at all is not a working Vulkan target either.
unbound="$test_tmp/pci-unbound"
mkdir -p "$unbound/0000:01:00.0"
echo "0x1002" >"$unbound/0000:01:00.0/vendor"
echo "0x030000" >"$unbound/0000:01:00.0/class"
result=$(installed_packages "$unbound")
[[ $result != *vulkan-radeon* ]] ||
  fail "vulkan-radeon is skipped when no driver is bound to the AMD GPU (got: $result)"
pass "an AMD GPU with no bound driver does not get vulkan-radeon"

# The AMD guard must not touch the other vendors' drivers.
result=$(STUB_GPU_VENDOR="Intel Corporation" installed_packages "$pre_gcn")
[[ $result == *vulkan-intel* ]] ||
  fail "Intel GPUs still get vulkan-intel regardless of the AMD guard (got: $result)"
pass "the AMD guard leaves vulkan-intel selection alone"
