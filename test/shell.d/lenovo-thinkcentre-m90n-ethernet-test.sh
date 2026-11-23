#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

script="$ROOT/install/hardware/lenovo/fix-thinkcentre-m90n-ethernet.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

make_pci_tree() {
  local dir="$1" vendor="$2" device="$3" class="$4"
  mkdir -p "$dir/0000:00:1f.6"
  printf '0x%s\n' "$vendor" >"$dir/0000:00:1f.6/vendor"
  printf '0x%s\n' "$device" >"$dir/0000:00:1f.6/device"
  printf '0x%s\n' "$class" >"$dir/0000:00:1f.6/class"
}

make_stubs() {
  local dir="$1" is_x86="$2" match_model="$3"
  mkdir -p "$dir"

  cat >"$dir/omarchy-hw-x86" <<SH
#!/bin/bash
exit $is_x86
SH
  cat >"$dir/omarchy-hw-match" <<SH
#!/bin/bash
[[ "\${1:-}" == "ThinkCentre M90n-1" ]] && exit $match_model
exit 1
SH
  chmod +x "$dir/omarchy-hw-x86" "$dir/omarchy-hw-match"
}

# 1. Matching ThinkCentre M90n-1 with Intel I219-V (8086:15be) writes the drop-in.
case1="$test_tmp/match"
make_pci_tree "$case1/pci" 8086 15be 020000
make_stubs "$case1/bin" 0 0
OMARCHY_PCI_DEVICES_PATH="$case1/pci" \
  OMARCHY_THINKCENTRE_M90N_LIMINE_CONFIG_DIR="$case1/limine" \
  PATH="$case1/bin:$ROOT/bin:$PATH" \
  bash -euo pipefail "$script"

drop_in="$case1/limine/lenovo-thinkcentre-m90n-ethernet.conf"
[[ -f $drop_in ]] || fail "ThinkCentre M90n-1 with I219-V writes the Limine drop-in"
grep -Fq 'KERNEL_CMDLINE[default]+=" pcie_aspm=off"' "$drop_in" ||
  fail "Limine drop-in appends pcie_aspm=off" "$(cat "$drop_in")"
pass "ThinkCentre M90n-1 with Intel I219-V writes the pcie_aspm=off drop-in"

# 2. Other models with the same Intel I219-V PCI ID are left untouched.
case2="$test_tmp/other-model"
make_pci_tree "$case2/pci" 8086 15be 020000
make_stubs "$case2/bin" 0 1
OMARCHY_PCI_DEVICES_PATH="$case2/pci" \
  OMARCHY_THINKCENTRE_M90N_LIMINE_CONFIG_DIR="$case2/limine" \
  PATH="$case2/bin:$ROOT/bin:$PATH" \
  bash -euo pipefail "$script"

[[ ! -e "$case2/limine/lenovo-thinkcentre-m90n-ethernet.conf" ]] ||
  fail "other models with 8086:15be do not receive pcie_aspm=off"
pass "non-M90n-1 machines with Intel I219-V are not modified"

# 3. Matching model without Intel I219-V (8086:15be) is left untouched.
case3="$test_tmp/other-nic"
make_pci_tree "$case3/pci" 8086 15b8 020000
make_stubs "$case3/bin" 0 0
OMARCHY_PCI_DEVICES_PATH="$case3/pci" \
  OMARCHY_THINKCENTRE_M90N_LIMINE_CONFIG_DIR="$case3/limine" \
  PATH="$case3/bin:$ROOT/bin:$PATH" \
  bash -euo pipefail "$script"

[[ ! -e "$case3/limine/lenovo-thinkcentre-m90n-ethernet.conf" ]] ||
  fail "machines without 8086:15be do not receive pcie_aspm=off"
pass "machines without Intel I219-V (8086:15be) are not modified"
