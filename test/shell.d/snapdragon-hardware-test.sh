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

# Omarchy's own kernel keeps its device trees under its package name. They come
# before Arch Linux ARM's, so the trees match the kernel that boots.
mkdir -p "$scratch/dtbroot/qcom" "$scratch/dtbroot/linux-omarchy/qcom"
: >"$scratch/dtbroot/qcom/x1e80100-stock.dtb"
: >"$scratch/dtbroot/linux-omarchy/qcom/x1e80100-own.dtb"
run_dtb_root_setup() (
  omarchy-hw-aarch64-qualcomm() { return 0; }
  omarchy-pkg-add() { :; }

  OMARCHY_QUALCOMM_DTB_ROOT="$scratch/dtbroot"
  OMARCHY_QUALCOMM_UKI_CONFIG="$scratch/uki-root.conf"
  source "$dtb_setup"
)
run_dtb_root_setup
grep -Fq "DeviceTreeAuto=$scratch/dtbroot/linux-omarchy/qcom/x1e80100-own.dtb" "$scratch/uki-root.conf" ||
  fail "Snapdragon DTB setup takes the device trees of Omarchy's own kernel first"
rm -r "$scratch/dtbroot/linux-omarchy"
run_dtb_root_setup
grep -Fq "DeviceTreeAuto=$scratch/dtbroot/qcom/x1e80100-stock.dtb" "$scratch/uki-root.conf" ||
  fail "Snapdragon DTB setup falls back to Arch Linux ARM's device trees"

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
for script in "$kernel_params_setup" "$initramfs_setup"; do
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
  OMARCHY_QUALCOMM_MKINITCPIO_DIR="$out/mkinitcpio.conf.d"
  source "$firmware_setup"
  source "$dtb_setup"
  source "$out/kernel-params.sh"
  source "$initramfs_setup"
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

for platform in aarch64 aarch64-apple x86; do
  run_leaves_on "$platform"
  for written in modprobe.d uki.conf limine-entry-tool.d mkinitcpio.conf.d; do
    [[ ! -e $scratch/on/$platform/$written ]] ||
      fail "$platform gets no Snapdragon setup ($written)"
  done
done
pass "Snapdragon setup follows the real platform detector"

# The A16 hook must not follow a portable installation onto another board.
a16_setup="$ROOT/install/hardware/asus/fix-asus-zenbook-a16-dsp.sh"
a16_out="$scratch/a16"
mkdir -p "$a16_out"
sed "s|/etc/|$a16_out/etc/|g" "$a16_setup" >"$a16_out/setup.sh"

run_a16_setup() (
  local compatible=$1
  fake_platform "$scratch/a16-platform" aarch64-qualcomm
  printf '%s\0' "$compatible" qcom,glymur >"$scratch/a16-platform/proc/device-tree/compatible"
  export OMARCHY_PROC_ROOT="$scratch/a16-platform/proc"
  export PATH="$scratch/a16-platform/bin:$ROOT/bin:$PATH"
  omarchy-pkg-add() { printf '%s\n' "$*" >"$a16_out/packages"; }
  source "$a16_out/setup.sh"
)

for compatible in lenovo,yoga-slim7x microsoft,denali-oled qcom,x1p42100-crd qcom,glymur \
  asus,zenbook-a16-ux3607oa-other other-asus,zenbook-a16-ux3607oa; do
  run_a16_setup "$compatible"
  [[ ! -e $a16_out/packages && ! -e $a16_out/etc ]] || fail "A16 DSP setup leaves $compatible alone"
done
for platform in x86 aarch64 aarch64-apple; do
  (
    fake_platform "$scratch/a16-$platform" "$platform"
    export OMARCHY_PROC_ROOT="$scratch/a16-$platform/proc"
    export PATH="$scratch/a16-$platform/bin:$ROOT/bin:$PATH"
    omarchy-pkg-add() { fail "$platform must not install A16 firmware"; }
    source "$a16_out/setup.sh"
  )
  [[ ! -e $a16_out/etc ]] || fail "A16 DSP setup leaves $platform alone"
done
run_a16_setup asus,zenbook-a16-ux3607oa
[[ -s $a16_out/etc/initcpio/hooks/omarchy-a16-dsp ]] || fail "the A16 gets the DSP startup hook"
pass "A16 DSP installation is restricted to the exact board"

(
  export OMARCHY_PROC_ROOT="$scratch/a16-platform/proc"
  export PATH="$scratch/a16-platform/bin:$ROOT/bin:$PATH"
  config="$a16_out/etc/mkinitcpio.conf.d/zz-omarchy-a16-dsp.conf"
  for hooks in 'base udev modconf block encrypt filesystems' 'base udev modconf block filesystems'; do
    read -ra HOOKS <<<"$hooks"
    source "$config"
    first="${HOOKS[*]}"
    source "$config"
    [[ ${HOOKS[*]} == "$first" && $first == "base udev omarchy-a16-dsp "* ]] ||
      fail "A16 startup precedes root activation and is inserted once"
  done
  HOOKS=(base systemd sd-encrypt filesystems)
  if source "$config"; then fail "A16 startup refuses a systemd initramfs"; fi
  [[ ${HOOKS[*]} == 'base systemd sd-encrypt filesystems' ]] || fail "a refused hook layout is unchanged"
  printf '%s\0' microsoft,denali-oled qcom,x1e80100 >"$OMARCHY_PROC_ROOT/device-tree/compatible"
  HOOKS=(base udev modconf encrypt filesystems)
  source "$config"
  [[ ${HOOKS[*]} == 'base udev modconf encrypt filesystems' ]] || fail "a portable root rebuilt on another board gets no A16 hook"
)
pass "A16 DSP hook ordering preserves other boards and rejects unsupported initramfs layouts"

# Sysfs fixtures exercise the readiness decisions without loading a host module.
sys="$scratch/dsp-sys"
mkdir -p "$sys/firmware/devicetree/base" "$sys/class/typec/port0" "$sys/class/typec/port1" \
  "$sys/class/power_supply/battery" "$sys/bus/rpmsg/devices/pmic"
sed -e "s|/sys/|$sys/|g" -e "s|/etc/|$scratch/initrd-etc/|g" \
  "$ROOT/default/initcpio/hooks/omarchy-a16-dsp" >"$scratch/dsp-hook"
source "$scratch/dsp-hook"
for compatible in microsoft,denali-oled asus,zenbook-a16-ux3607oa-other; do
  printf '%s\0' "$compatible" qcom,glymur >"$sys/firmware/devicetree/base/compatible"
  if a16_dsp_board; then fail "the runtime guard rejects $compatible"; fi
  (
    modprobe() { fail "an A16 image must not start DSPs on $compatible"; }
    a16_dsp_stop() { fail "an A16 image must not hold boot on $compatible"; }
    run_earlyhook
    run_hook
  )
done
printf '%s\0' asus,zenbook-a16-ux3607oa qcom,glymur >"$sys/firmware/devicetree/base/compatible"
a16_dsp_board || fail "the runtime guard accepts the exact A16 compatible"
for pair in '7 adsp running' '3 cdsp running' '9 soccp attached'; do
  read -r index name state <<<"$pair"
  mkdir -p "$sys/class/remoteproc/remoteproc$index"
  printf '%s\n' "$name" >"$sys/class/remoteproc/remoteproc$index/name"
  printf '%s\n' "$state" >"$sys/class/remoteproc/remoteproc$index/state"
done
printf '%s\n' PMIC_RTR_SOCCP_APPS >"$sys/bus/rpmsg/devices/pmic/name"
ln -s /driver "$sys/bus/rpmsg/devices/pmic/driver"
echo Battery >"$sys/class/power_supply/battery/type"
echo 13000000 >"$sys/class/power_supply/battery/voltage_now"
a16_dsp_ready || fail "running DSPs, attached SoCCP and ready clients permit boot"
echo offline >"$sys/class/remoteproc/remoteproc7/state"
if a16_dsp_ready; then fail "an offline DSP must hold root activation"; fi
echo crashed >"$sys/class/remoteproc/remoteproc7/state"
status=0
a16_dsp_ready || status=$?
(( status == 2 )) || fail "a crashed DSP reports a fatal startup failure"
echo running >"$sys/class/remoteproc/remoteproc7/state"
for voltage in '' 0 unknown; do
  printf '%s\n' "$voltage" >"$sys/class/power_supply/battery/voltage_now"
  if a16_dsp_ready; then fail "an unreadable battery holds root activation"; fi
done
echo 13000000 >"$sys/class/power_supply/battery/voltage_now"
rm "$sys/bus/rpmsg/devices/pmic/driver"
if a16_dsp_ready; then fail "an unbound PMIC service holds root activation"; fi
ln -s /driver "$sys/bus/rpmsg/devices/pmic/driver"
rmdir "$sys/class/typec/port1"
if a16_dsp_ready; then fail "missing Type-C initialization holds root activation"; fi
pass "A16 readiness waits for firmware and its PMIC clients, independent of remoteproc numbering"
