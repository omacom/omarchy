#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fix_imac20="$ROOT/install/hardware/apple/fix-imac20-display.sh"
all_hardware="$ROOT/install/hardware/all.sh"
hw_detector="$ROOT/bin/omarchy-hw-imac20-navi14"
migration="$ROOT/migrations/1789574960.sh"

grep -Fq 'run_logged "$OMARCHY_INSTALL/hardware/apple/fix-imac20-display.sh"' "$all_hardware" ||
  fail "hardware setup runs the 2020 iMac display workaround"
grep -Fq 'omarchy-hw-imac20-navi14' "$fix_imac20" ||
  fail "iMac display setup uses the Navi 14 detector"
grep -Fq 'KERNEL_CMDLINE[default]+=" plymouth.enable=0 nomodeset"' "$fix_imac20" ||
  fail "iMac display setup persists plymouth.enable=0 nomodeset"
grep -Fq 'imac20-display.conf' "$fix_imac20" ||
  fail "iMac display setup writes a Limine drop-in"
pass "fresh 2020 iMac setup keeps the EFI framebuffer through LUKS"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

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

write_product_name() {
  printf '%s\n' "$1" >"$tmp_dir/product_name"
}

detects_imac20_navi14() {
  OMARCHY_DMI_PRODUCT_NAME="$tmp_dir/product_name" \
    OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" \
    "$hw_detector"
}

write_product_name "iMac20,1"
write_pci_devices 0x1002:0x7340:0x030000
detects_imac20_navi14 || fail "iMac20,1 with Navi 14 is detected"
pass "iMac20,1 with Navi 14 is detected"

write_product_name "iMac20,2"
write_pci_devices 0x1002:0x7340:0x030000
detects_imac20_navi14 || fail "iMac20,2 with Navi 14 is detected"
pass "iMac20,2 with Navi 14 is detected"

write_product_name "MacBookPro16,1"
write_pci_devices 0x1002:0x7340:0x030000
detects_imac20_navi14 && fail "a Navi 14 MacBook Pro is not treated as a 2020 iMac"
pass "a Navi 14 MacBook Pro is not treated as a 2020 iMac"

write_product_name "iMac20,1"
write_pci_devices 0x1002:0x731f:0x030000
detects_imac20_navi14 && fail "a 2020 iMac with Navi 10 is left alone"
pass "a 2020 iMac with Navi 10 is left alone"

write_product_name "iMac20,1"
write_pci_devices 0x1002:0x7340:0x040300
detects_imac20_navi14 && fail "Navi 14 HDMI audio is not a GPU"
pass "Navi 14 HDMI audio is not a GPU"

write_product_name "iMac19,1"
write_pci_devices 0x1002:0x7340:0x030000
detects_imac20_navi14 && fail "a 2019 iMac is left alone"
pass "a 2019 iMac is left alone"

stub_bin="$tmp_dir/bin"
calls="$tmp_dir/calls.log"
mkdir -p "$stub_bin"
: >"$calls"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
"$@"
SH

cat >"$stub_bin/limine-mkinitcpio" <<'SH'
#!/bin/bash

echo 'limine-mkinitcpio' >>"$TEST_LOG"
SH

chmod +x "$stub_bin"/*

limine_conf="$tmp_dir/imac20-display.conf"
running_cmdline="$tmp_dir/cmdline"
repair_marker="$tmp_dir/imac20-repair-complete"
product_name="$tmp_dir/product_name"
pci_devices="$tmp_dir/devices"

write_product_name "iMac20,1"
write_pci_devices 0x1002:0x7340:0x030000
echo 'quiet splash intel_iommu=on' >"$running_cmdline"

PATH="$stub_bin:$ROOT/bin:$PATH" \
  TEST_LOG="$calls" \
  OMARCHY_DMI_PRODUCT_NAME="$product_name" \
  OMARCHY_PCI_DEVICES_PATH="$pci_devices" \
  OMARCHY_IMAC20_DISPLAY_CONF="$limine_conf" \
  OMARCHY_IMAC20_RUNNING_CMDLINE="$running_cmdline" \
  OMARCHY_IMAC20_REPAIR_MARKER="$repair_marker" \
  bash -euo pipefail "$migration" >/dev/null

grep -Fq 'KERNEL_CMDLINE[default]+=" plymouth.enable=0 nomodeset"' "$limine_conf" ||
  fail "iMac display migration writes the Limine drop-in"
grep -Fxq 'limine-mkinitcpio' "$calls" ||
  fail "iMac display migration rebuilds the boot image"
[[ -f $repair_marker ]] || fail "iMac display migration records the machine-wide repair"
pass "iMac display migration repairs existing installs"

: >"$calls"

PATH="$stub_bin:$ROOT/bin:$PATH" \
  TEST_LOG="$calls" \
  OMARCHY_DMI_PRODUCT_NAME="$product_name" \
  OMARCHY_PCI_DEVICES_PATH="$pci_devices" \
  OMARCHY_IMAC20_DISPLAY_CONF="$limine_conf" \
  OMARCHY_IMAC20_RUNNING_CMDLINE="$running_cmdline" \
  OMARCHY_IMAC20_REPAIR_MARKER="$repair_marker" \
  bash -euo pipefail "$migration" >/dev/null

[[ ! -s $calls ]] || fail "an already repaired 2020 iMac is left unchanged" "$(cat "$calls")"
pass "iMac display migration is machine-idempotent before reboot"

rm -f "$repair_marker"
: >"$calls"

PATH="$stub_bin:$ROOT/bin:$PATH" \
  TEST_LOG="$calls" \
  OMARCHY_DMI_PRODUCT_NAME="$product_name" \
  OMARCHY_PCI_DEVICES_PATH="$pci_devices" \
  OMARCHY_IMAC20_DISPLAY_CONF="$limine_conf" \
  OMARCHY_IMAC20_RUNNING_CMDLINE="$running_cmdline" \
  OMARCHY_IMAC20_REPAIR_MARKER="$repair_marker" \
  bash -euo pipefail "$migration" >/dev/null

grep -Fxq 'limine-mkinitcpio' "$calls" ||
  fail "iMac display migration retries an interrupted boot image rebuild"
[[ -f $repair_marker ]] || fail "a retried iMac display repair records completion"
! grep -Eq $'^(sudo\t)?(tee)(\t|$)' "$calls" ||
  fail "iMac rebuild retry leaves a completed drop-in alone" "$(cat "$calls")"
pass "iMac display migration retries an interrupted boot image rebuild"

rm -f "$limine_conf" "$repair_marker"
: >"$calls"
write_product_name "MacBookPro16,1"
echo 'quiet splash' >"$running_cmdline"

PATH="$stub_bin:$ROOT/bin:$PATH" \
  TEST_LOG="$calls" \
  OMARCHY_DMI_PRODUCT_NAME="$product_name" \
  OMARCHY_PCI_DEVICES_PATH="$pci_devices" \
  OMARCHY_IMAC20_DISPLAY_CONF="$limine_conf" \
  OMARCHY_IMAC20_RUNNING_CMDLINE="$running_cmdline" \
  OMARCHY_IMAC20_REPAIR_MARKER="$repair_marker" \
  bash -euo pipefail "$migration" >/dev/null

[[ ! -e $limine_conf ]] || fail "non-iMac Limine configuration is unchanged"
[[ ! -s $calls ]] || fail "unrelated hardware skips the repair" "$(cat "$calls")"
pass "iMac display migration skips unrelated hardware"
