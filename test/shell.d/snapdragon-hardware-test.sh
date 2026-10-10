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
  omarchy-hw-aarch64-qualcomm() { return 0; }
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
  omarchy-hw-aarch64-qualcomm() { return 0; }
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
  omarchy-hw-aarch64-qualcomm() { return 0; }
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

# An image's first boot rebuilds once after its last step and does not watch
# uki.conf, so a changed list asks for that rebuild and an unchanged one does not.
request="$scratch/boot-rebuild"
: >"$scratch/dtbs/x1e80100-added.dtb"
(export OMARCHY_IMAGE_BOOT_REBUILD="$request" && run_dtb_setup)
[[ -e $request ]] ||
  fail "a changed device tree list asks an image's first boot for the rebuild"
rm -f "$request"
(export OMARCHY_IMAGE_BOOT_REBUILD="$request" && run_dtb_setup)
[[ ! -e $request ]] ||
  fail "an unchanged device tree list asks for no rebuild"

pass "Snapdragon setup tolerates missing firmware and preserves UKI settings"

defaults=$(OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-pkg-defaults" aarch64-qualcomm)
for package in linux-firmware-qcom qcom-firmware-extract systemd-ukify vulkan-freedreno; do
  grep -qx "$package" <<<"$defaults" ||
    fail "the Snapdragon package set has $package for offline setup"
done
pass "the Snapdragon package set has every package its setup installs"

# The leaves ask omarchy-hw-aarch64-qualcomm, so run them under the real
# detector: a Snapdragon device tree gets the setup and no other platform does.
require_platform_fixtures "Snapdragon setup under the real detector"

kernel_params_setup="$ROOT/install/hardware/qualcomm/kernel-params.sh"
bash -n "$kernel_params_setup" || fail "Snapdragon hardware scripts have valid syntax"

run_leaves_on() (
  platform=$1
  out="$scratch/on/$platform"
  mkdir -p "$out"
  fake_platform "$scratch/platforms/$platform" "$platform"
  export OMARCHY_PROC_ROOT="$scratch/platforms/$platform/proc"
  export PATH="$scratch/platforms/$platform/bin:$ROOT/bin:$PATH"

  omarchy-pkg-add() { :; }
  qcom-firmware-extract() { [[ $1 != "--list-missing" ]]; }
  findmnt() { printf '/dev/mapper/root\n'; }
  lsblk() { printf 'nvme\n'; }

  # kernel-params.sh writes a fixed path, so run a copy that writes the fixture.
  sed "s|/etc/limine-entry-tool.d|$out/limine-entry-tool.d|g" "$kernel_params_setup" >"$out/kernel-params.sh"

  OMARCHY_QUALCOMM_MODPROBE_DIR="$out/modprobe.d"
  OMARCHY_QUALCOMM_DTB_DIR="$scratch/dtbs"
  OMARCHY_QUALCOMM_UKI_CONFIG="$out/uki.conf"
  source "$firmware_setup"
  source "$dtb_setup"
  source "$out/kernel-params.sh"
)

run_leaves_on aarch64-qualcomm
snapdragon="$scratch/on/aarch64-qualcomm"
[[ -f $snapdragon/modprobe.d/qualcomm-adsp-nofw.conf ]] ||
  fail "a Snapdragon device tree gets the firmware setup"
grep -Fq "DeviceTreeAuto=" "$snapdragon/uki.conf" ||
  fail "a Snapdragon device tree gets the device tree list"
(
  declare -A KERNEL_CMDLINE=([default]="quiet splash")
  source "$snapdragon/limine-entry-tool.d/qualcomm-snapdragon.conf"
  for parameter in clk_ignore_unused pd_ignore_unused arm64.nopauth systemd.tpm2_wait=0; do
    [[ " ${KERNEL_CMDLINE[default]} " == *" $parameter "* ]] ||
      fail "a Snapdragon device tree boots with $parameter"
  done
  [[ ${KERNEL_CMDLINE[default]} == "quiet splash "* ]] ||
    fail "Snapdragon setup preserves the existing boot parameters"
)

for platform in aarch64 aarch64-apple x86; do
  run_leaves_on "$platform"
  for written in modprobe.d uki.conf limine-entry-tool.d; do
    [[ ! -e $scratch/on/$platform/$written ]] ||
      fail "$platform gets no Snapdragon setup ($written)"
  done
done
pass "Snapdragon setup follows the real platform detector"
