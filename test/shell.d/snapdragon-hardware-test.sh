#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

firmware_setup="$ROOT/install/hardware/qualcomm/firmware.sh"
dtb_setup="$ROOT/install/hardware/qualcomm/dtb-uki.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

for script in "$firmware_setup" "$dtb_setup"; do
  bash -n "$script" || fail "Snapdragon hardware scripts have valid syntax"
done

(
  omarchy-hw-qualcomm-soc() { return 0; }
  omarchy-pkg-add() { :; }
  qcom-firmware-extract() {
    if [[ $1 == "--install" ]]; then
      return 1
    else
      return 0
    fi
  }
  findmnt() {
    [[ $* == "-no SOURCE --nofsroot /" ]] || fail "Snapdragon firmware setup strips the Btrfs subvolume suffix"
    printf '/dev/mapper/root\n'
  }
  lsblk() {
    [[ ${!#} == "/dev/mapper/root" ]] || fail "Snapdragon firmware setup passes a resolvable root device to lsblk"
    printf 'usb\n'
  }

  OMARCHY_QUALCOMM_MODPROBE_DIR="$scratch/modprobe.d"
  source "$firmware_setup"
)

[[ -f $scratch/modprobe.d/qualcomm-adsp-nofw.conf ]] ||
  fail "Snapdragon firmware setup protects a USB-backed root disk"

run_internal_firmware_setup() (
  omarchy-hw-qualcomm-soc() { return 0; }
  omarchy-pkg-add() { :; }
  findmnt() { printf '/dev/mapper/root\n'; }
  lsblk() { printf 'nvme\n'; }
  inspection_status=$1
  qcom-firmware-extract() {
    [[ $1 == "--list-missing" ]] || return 0
    return "$inspection_status"
  }
  OMARCHY_QUALCOMM_MODPROBE_DIR="$scratch/modprobe.d"
  source "$firmware_setup"
)

run_internal_firmware_setup 1
[[ -f $scratch/modprobe.d/qualcomm-adsp-nofw.conf ]] ||
  fail "Snapdragon setup keeps DSPs disabled when firmware inspection fails"
run_internal_firmware_setup 0
[[ ! -f $scratch/modprobe.d/qualcomm-adsp-nofw.conf ]] ||
  fail "Snapdragon setup enables DSPs after firmware is verified on an internal root"

mkdir -p "$scratch/dtbs"
: >"$scratch/dtbs/x1e80100-test.dtb"
: >"$scratch/dtbs/x1e80100-test-el2.dtb"
cat >"$scratch/uki.conf" <<'CONF'
[UKI]
SecureBootPrivateKey=/secure/db.key
PCRPrivateKey=/secure/pcr.key
CONF

run_dtb_setup() (
  omarchy-hw-qualcomm-soc() { return 0; }
  omarchy-pkg-add() { :; }

  OMARCHY_QUALCOMM_DTB_DIR="$scratch/dtbs"
  OMARCHY_QUALCOMM_UKI_CONFIG="$scratch/uki.conf"
  source "$dtb_setup"
)

run_dtb_setup
first_uki_config=$(<"$scratch/uki.conf")
run_dtb_setup
[[ $(<"$scratch/uki.conf") == "$first_uki_config" ]] ||
  fail "Snapdragon DTB setup is idempotent"

grep -Fq 'SecureBootPrivateKey=/secure/db.key' "$scratch/uki.conf" ||
  fail "Snapdragon DTB setup preserves Secure Boot settings"
grep -Fq 'PCRPrivateKey=/secure/pcr.key' "$scratch/uki.conf" ||
  fail "Snapdragon DTB setup preserves PCR settings"
[[ $(grep -Fc '# BEGIN OMARCHY QUALCOMM DEVICE TREES' "$scratch/uki.conf") == 1 ]] ||
  fail "Snapdragon DTB setup keeps one managed UKI block"
grep -Fq "DeviceTreeAuto=$scratch/dtbs/x1e80100-test.dtb" "$scratch/uki.conf" ||
  fail "Snapdragon DTB setup lists the matching device tree"
if grep -Fq 'x1e80100-test-el2.dtb' "$scratch/uki.conf"; then
  fail "Snapdragon DTB setup excludes EL2-only device trees"
fi

pass "Snapdragon setup tolerates missing firmware and preserves UKI settings"
