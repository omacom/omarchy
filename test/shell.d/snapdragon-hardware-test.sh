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
: >"$scratch/dtbs/mahua-test.dtb"
cat >"$scratch/uki.conf" <<'CONF'
[UKI]
SecureBootPrivateKey=/secure/db.key
PCRPrivateKey=/secure/pcr.key
CONF

run_dtb_setup() (
  omarchy-hw-aarch64-qualcomm() { return 0; }
  omarchy-pkg-add() { :; }

  PATH="$ROOT/bin:$PATH"
  OMARCHY_PROC_ROOT="$scratch/no-proc"
  OMARCHY_QUALCOMM_DTB_DIR="$scratch/dtbs"
  OMARCHY_QUALCOMM_UKI_CONFIG="$scratch/uki.conf"
  OMARCHY_QUALCOMM_BOOT_HOOKS_DIR="$scratch/boot-hooks"
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
grep -Fq "$scratch/dtbs/mahua-test.dtb" "$scratch/uki.conf" ||
  fail "Snapdragon DTB setup lists the Mahua device trees"
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

# limine refreshes the list before every boot image build, so a tree a kernel
# update brings reaches the image. A configuration without Omarchy's list, like
# the Surface Pro 11's pinned tree, stays as it is, and no build stops on it.
refresh="$ROOT/bin/omarchy-update-qualcomm-device-trees"
[[ $(readlink "$scratch/boot-hooks/20-omarchy-qualcomm-device-trees") == "/usr/bin/omarchy-update-qualcomm-device-trees" ]] ||
  fail "Snapdragon DTB setup refreshes the list before every boot image build"
: >"$scratch/dtbs/glymur-update.dtb"
OMARCHY_PROC_ROOT="$scratch/no-proc" OMARCHY_QUALCOMM_DTB_DIR="$scratch/dtbs" OMARCHY_QUALCOMM_UKI_CONFIG="$scratch/uki.conf" "$refresh" >/dev/null
grep -Fq "$scratch/dtbs/glymur-update.dtb" "$scratch/uki.conf" ||
  fail "a device tree a kernel update brings reaches the list"
printf '[UKI]\nDeviceTree=/boot/dtbs/qcom/pinned.dtb\n' >"$scratch/pinned.conf"
cp -p "$scratch/pinned.conf" "$scratch/pinned-before.conf"
OMARCHY_PROC_ROOT="$scratch/no-proc" OMARCHY_QUALCOMM_DTB_DIR="$scratch/dtbs" OMARCHY_QUALCOMM_UKI_CONFIG="$scratch/pinned.conf" "$refresh" ||
  fail "the device tree refresh never stops a boot image build"
cmp -s "$scratch/pinned.conf" "$scratch/pinned-before.conf" ||
  fail "the device tree refresh leaves a configuration without Omarchy's list alone"
# A copy it can't finish writing never replaces the configuration (root reads
# through the lock, so only an unprivileged run can stage the failure).
if (( EUID != 0 )); then
  cp -p "$scratch/uki.conf" "$scratch/locked.conf"
  chmod 000 "$scratch/locked.conf"
  OMARCHY_PROC_ROOT="$scratch/no-proc" OMARCHY_QUALCOMM_DTB_DIR="$scratch/dtbs" OMARCHY_QUALCOMM_UKI_CONFIG="$scratch/locked.conf" "$refresh" --install 2>/dev/null ||
    fail "a failed device tree list write never stops a boot image build"
  chmod 600 "$scratch/locked.conf"
  cmp -s "$scratch/locked.conf" "$scratch/uki.conf" ||
    fail "a failed device tree list write leaves the configuration as it was"
fi

# Omarchy's own kernel keeps its device trees under its package name. They come
# before Arch Linux ARM's, so the trees match the kernel that boots.
mkdir -p "$scratch/dtbroot/qcom" "$scratch/dtbroot/linux-omarchy/qcom"
: >"$scratch/dtbroot/qcom/x1e80100-stock.dtb"
: >"$scratch/dtbroot/linux-omarchy/qcom/x1e80100-own.dtb"
run_dtb_root_setup() (
  omarchy-hw-aarch64-qualcomm() { return 0; }
  omarchy-pkg-add() { :; }

  PATH="$ROOT/bin:$PATH"
  OMARCHY_PROC_ROOT="$scratch/no-proc"
  OMARCHY_QUALCOMM_DTB_ROOT="$scratch/dtbroot"
  OMARCHY_QUALCOMM_UKI_CONFIG="$scratch/uki-root.conf"
  OMARCHY_QUALCOMM_BOOT_HOOKS_DIR="$scratch/boot-hooks"
  source "$dtb_setup"
)
run_dtb_root_setup
grep -Fq "DeviceTreeAuto=$scratch/dtbroot/linux-omarchy/qcom/x1e80100-own.dtb" "$scratch/uki-root.conf" ||
  fail "Snapdragon DTB setup takes the device trees of Omarchy's own kernel first"
# A second kernel named after it, as a test build is, sorts ahead of it.
mkdir -p "$scratch/dtbroot/linux-omarchy-test/qcom"
: >"$scratch/dtbroot/linux-omarchy-test/qcom/x1e80100-test-kernel.dtb"
run_dtb_root_setup
grep -Fq "DeviceTreeAuto=$scratch/dtbroot/linux-omarchy/qcom/x1e80100-own.dtb" "$scratch/uki-root.conf" ||
  fail "Snapdragon DTB setup takes linux-omarchy's device trees before another linux-omarchy kernel's"
rm -r "$scratch/dtbroot/linux-omarchy"
run_dtb_root_setup
grep -Fq "DeviceTreeAuto=$scratch/dtbroot/linux-omarchy-test/qcom/x1e80100-test-kernel.dtb" "$scratch/uki-root.conf" ||
  fail "Snapdragon DTB setup takes another linux-omarchy kernel's device trees when linux-omarchy has none"
rm -r "$scratch/dtbroot/linux-omarchy-test"
run_dtb_root_setup
grep -Fq "DeviceTreeAuto=$scratch/dtbroot/qcom/x1e80100-stock.dtb" "$scratch/uki-root.conf" ||
  fail "Snapdragon DTB setup falls back to Arch Linux ARM's device trees"

# An installed machine embeds its own tree beside the list, the one whose root
# compatible is the running device tree's byte for byte, for systemd-stub to
# fall back on when no hardware ID matches. The Acer tree also names the
# ThinkPad T14s, as a fallback, so the T14s's list must not match inside it.
own="$scratch/own"
mkdir -p "$own/proc/device-tree" "$own/dtbs"
acer='acer,swift-go14-01\0lenovo,thinkpad-t14s\0qcom,x1p42100\0qcom,x1e80100\0'
t14s='lenovo,thinkpad-t14s\0qcom,x1e78100\0qcom,x1e80100\0'
# A tree's compatible property: its token, length and name offset, then the
# strings. Offset 10 is a newline byte, as a real tree's can be.
fake_dtb() {
  printf "\xd0\x0d\xfe\xed\0\0\0\x03\0\0\0\x$(printf "$2" | wc -c | xargs printf %02x)\0\0\0\x0a$2\0\0\0\x09" >"$1"
}
fake_dtb "$own/dtbs/x1p42100-acer-swift-go14-01.dtb" "$acer"
fake_dtb "$own/dtbs/x1e78100-lenovo-thinkpad-t14s.dtb" "$t14s"
run_own_dtb_setup() (
  omarchy-hw-aarch64-qualcomm() { return 0; }
  omarchy-pkg-add() { :; }

  PATH="$ROOT/bin:$PATH"
  OMARCHY_PROC_ROOT="$own/proc"
  OMARCHY_QUALCOMM_DTB_DIR="$own/dtbs"
  OMARCHY_QUALCOMM_UKI_CONFIG="$own/uki.conf"
  OMARCHY_QUALCOMM_BOOT_HOOKS_DIR="$own/boot-hooks"
  source "$dtb_setup"
)
printf "$acer" >"$own/proc/device-tree/compatible"
run_own_dtb_setup
grep -qx "DeviceTree=$own/dtbs/x1p42100-acer-swift-go14-01.dtb" "$own/uki.conf" ||
  fail "an installed Snapdragon machine embeds its own device tree"
grep -qx "DeviceTreeAuto=$own/dtbs/x1e78100-lenovo-thinkpad-t14s.dtb $own/dtbs/x1p42100-acer-swift-go14-01.dtb" "$own/uki.conf" ||
  fail "a machine with its own device tree keeps the list, so its hardware IDs still choose"
# The refresh before every boot image build follows a kernel update that
# renames the machine's tree.
mv "$own/dtbs/x1p42100-acer-swift-go14-01.dtb" "$own/dtbs/x1p42100-acer-swift-go14.dtb"
OMARCHY_PROC_ROOT="$own/proc" OMARCHY_QUALCOMM_DTB_DIR="$own/dtbs" OMARCHY_QUALCOMM_UKI_CONFIG="$own/uki.conf" "$refresh" >/dev/null
grep -qx "DeviceTree=$own/dtbs/x1p42100-acer-swift-go14.dtb" "$own/uki.conf" ||
  fail "the refresh before a boot image build keeps the machine's own tree when a kernel update renames it"
mv "$own/dtbs/x1p42100-acer-swift-go14.dtb" "$own/dtbs/x1p42100-acer-swift-go14-01.dtb"
printf "$t14s" >"$own/proc/device-tree/compatible"
run_own_dtb_setup
grep -qx "DeviceTree=$own/dtbs/x1e78100-lenovo-thinkpad-t14s.dtb" "$own/uki.conf" ||
  fail "a compatible another tree names as a fallback still finds its own tree"
cp "$own/dtbs/x1e78100-lenovo-thinkpad-t14s.dtb" "$own/dtbs/x1e78100-lenovo-thinkpad-t14s-copy.dtb"
run_own_dtb_setup
grep -q '^DeviceTreeAuto=' "$own/uki.conf" && ! grep -q '^DeviceTree=' "$own/uki.conf" ||
  fail "two trees with the machine's compatible leave the choice to systemd-stub"
rm "$own/dtbs/x1e78100-lenovo-thinkpad-t14s-copy.dtb"
fake_dtb "$own/dtbs/x1e80100-microsoft-denali-oled.dtb" 'microsoft,denali-oled\0microsoft,denali\0qcom,x1e80100\0'
printf 'microsoft,denali\0qcom,x1e80100\0' >"$own/proc/device-tree/compatible"
run_own_dtb_setup
grep -q '^DeviceTreeAuto=' "$own/uki.conf" && ! grep -q '^DeviceTree=' "$own/uki.conf" ||
  fail "a machine without its own tree does not take one whose longer list ends with its own"
rm "$own/proc/device-tree/compatible"
run_own_dtb_setup
grep -q '^DeviceTreeAuto=' "$own/uki.conf" && ! grep -q '^DeviceTree=' "$own/uki.conf" ||
  fail "a machine with no running device tree keeps every tree"

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
initramfs_setup="$ROOT/install/hardware/qualcomm/initramfs.sh"
reboot_watchdog_setup="$ROOT/install/hardware/qualcomm/reboot-watchdog.sh"
for script in "$kernel_params_setup" "$initramfs_setup" "$reboot_watchdog_setup"; do
  bash -n "$script" || fail "Snapdragon hardware scripts have valid syntax"
done

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
  OMARCHY_QUALCOMM_BOOT_HOOKS_DIR="$out/boot-hooks"
  OMARCHY_QUALCOMM_MKINITCPIO_DIR="$out/mkinitcpio.conf.d"
  OMARCHY_QUALCOMM_INITCPIO_INSTALL_DIR="$out/initcpio-install"
  OMARCHY_QUALCOMM_SYSTEM_CONF_DIR="$out/system.conf.d"
  source "$firmware_setup"
  source "$dtb_setup"
  source "$out/kernel-params.sh"
  source "$initramfs_setup"
  source "$reboot_watchdog_setup"
)

run_leaves_on aarch64-qualcomm
snapdragon="$scratch/on/aarch64-qualcomm"
[[ -f $snapdragon/modprobe.d/qualcomm-adsp-nofw.conf ]] ||
  fail "a Snapdragon device tree gets the firmware setup"
grep -Fq "DeviceTreeAuto=" "$snapdragon/uki.conf" ||
  fail "a Snapdragon device tree gets the device tree list"
grep -Fqx "RebootWatchdogSec=off" "$snapdragon/system.conf.d/60-omarchy-qualcomm-reboot-watchdog.conf" ||
  fail "a Snapdragon device tree stops asking its watchdog for ten minutes at shutdown"
(
  declare -A KERNEL_CMDLINE=([default]="quiet splash")
  source "$snapdragon/limine-entry-tool.d/qualcomm-snapdragon.conf"
  for parameter in clk_ignore_unused pd_ignore_unused arm64.nopauth systemd.tpm2_wait=0 iommu.passthrough=0; do
    [[ " ${KERNEL_CMDLINE[default]} " == *" $parameter "* ]] ||
      fail "a Snapdragon device tree boots with $parameter"
  done
  [[ ${KERNEL_CMDLINE[default]} == "quiet splash "* ]] ||
    fail "Snapdragon setup preserves the existing boot parameters"
)

(
  # A kernel that builds the X1 platform drivers as modules gets them named for
  # the initramfs, each one optional so another kernel's image still builds.
  MODULES=(first)
  source "$snapdragon/mkinitcpio.conf.d/qualcomm-platform.conf"
  [[ ${MODULES[0]} == first ]] ||
    fail "Snapdragon setup preserves the initramfs modules already named"
  for module in pinctrl-x1e80100 qnoc-x1e80100 spmi-pmic-arb i2c-qcom-geni; do
    [[ " ${MODULES[*]} " == *" $module? "* ]] ||
      fail "a Snapdragon device tree gets $module in its initramfs"
  done
  for module in "${MODULES[@]:1}"; do
    [[ $module == *\? ]] ||
      fail "every Snapdragon platform module is optional ($module)"
  done
)

(
  # The hook quiets mkinitcpio's efivarfs mount, which fails on Snapdragon
  # until the QSEECOM driver loads, in the image's copy of init_functions.
  HOOKS=(base)
  source "$snapdragon/mkinitcpio.conf.d/qualcomm-platform.conf"
  [[ ${HOOKS[*]} == "base omarchy-quiet-efivars" ]] ||
    fail "a Snapdragon device tree runs omarchy-quiet-efivars after base"

  BUILDROOT="$scratch/buildroot"
  mkdir -p "$BUILDROOT"
  printf '%s\n' 'mount_setup() {' \
    '    if [ -e /sys/firmware/efi ]; then' \
    '        mount -t efivarfs efivarfs /sys/firmware/efi/efivars -o nosuid,nodev,noexec' \
    '    fi' '}' >"$BUILDROOT/init_functions"
  source "$snapdragon/initcpio-install/omarchy-quiet-efivars"
  build
  grep -Fqx '        mount -t efivarfs efivarfs /sys/firmware/efi/efivars -o nosuid,nodev,noexec 2>/dev/null' "$BUILDROOT/init_functions" ||
    fail "omarchy-quiet-efivars quiets mkinitcpio's efivarfs mount"
)

for platform in aarch64 aarch64-apple x86; do
  run_leaves_on "$platform"
  for written in modprobe.d uki.conf boot-hooks limine-entry-tool.d mkinitcpio.conf.d initcpio-install system.conf.d; do
    [[ ! -e $scratch/on/$platform/$written ]] ||
      fail "$platform gets no Snapdragon setup ($written)"
  done
done
pass "Snapdragon setup follows the real platform detector"
