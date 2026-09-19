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
    printf '%s\n' "${spec##*:}" >"$tmp/devices/$slot/class"
    index=$((index + 1))
  done
}

stub_bin="$tmp/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >>"$OMARCHY_TEST_VULKAN_PKGS"
SH
chmod +x "$stub_bin/omarchy-pkg-add"

run_vulkan() {
  : >"$tmp/pkgs"
  OMARCHY_PCI_DEVICES_PATH="$tmp/devices" \
    OMARCHY_TEST_VULKAN_PKGS="$tmp/pkgs" \
    PATH="$stub_bin:$PATH" \
    bash "$ROOT/install/hardware/vulkan.sh"
}

write_pci 0x8086:0x030000
run_vulkan
grep -Fxq 'vulkan-intel' "$tmp/pkgs" || fail "Intel display gets vulkan-intel" "$(cat "$tmp/pkgs")"
pass "Intel display installs vulkan-intel from sysfs"

write_pci 0x1002:0x030000 0x10de:0x030200
run_vulkan
grep -Fxq 'vulkan-radeon' "$tmp/pkgs" || fail "AMD iGPU gets vulkan-radeon on a hybrid machine"
! grep -q nvidia "$tmp/pkgs" || fail "NVIDIA Vulkan stays with nvidia.sh"
pass "hybrid AMD+NVIDIA only adds vulkan-radeon here"

write_pci 0x8086:0x040300
run_vulkan
[[ ! -s $tmp/pkgs ]] || fail "an Intel audio function is not a GPU" "$(cat "$tmp/pkgs")"
pass "non-display PCI functions do not pull Vulkan drivers"

grep -Fq 'OMARCHY_PCI_DEVICES_PATH' "$ROOT/install/hardware/vulkan.sh" ||
  fail "Vulkan install reads the same sysfs override as omarchy-hw-nvidia"
! grep -E '^[^#]*lspci' "$ROOT/install/hardware/vulkan.sh" ||
  fail "Vulkan install no longer shells out to lspci"
pass "Vulkan install does not wake GPUs via lspci"
