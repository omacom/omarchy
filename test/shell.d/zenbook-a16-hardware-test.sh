#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/asus/zenbook-a16.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

for script in "$setup" "$ROOT/install/hardware/asus/zenbook-a16-early-dsp.sh"; do
  bash -n "$script" || fail "ASUS Zenbook A16 hardware scripts have valid syntax"
done

require_platform_fixtures "the Zenbook A16 device-tree gate"
export PATH="$ROOT/bin:$PATH"

# The board leaf requires the coordinated shared-kernel/support package set.
mkdir -p "$scratch/support" "$scratch/doc/linux-omarchy" "$scratch/modules/test-kernel"
echo '# package-owned profile' > "$scratch/support/mkinitcpio.conf"
echo 'blacklist qcom_q6v5_pas' > "$scratch/support/remoteproc-blacklist.conf"
echo '# A16 audio policy' > "$scratch/support/51-glymur-ucm.conf"
echo test-kernel > "$scratch/doc/linux-omarchy/kernel-release"
echo 1 > "$scratch/modules/test-kernel/omarchy-a16-dsp-abi"
echo 'root=/dev/mapper/root rw' > "$scratch/cmdline"
omarchy-pkg-present() { [[ $* == "linux-omarchy omarchy-a16-support" ]]; }
export OMARCHY_INSTALL="$ROOT/install"
export OMARCHY_ZENBOOK_SUPPORT_DIR="$scratch/support"
export OMARCHY_ZENBOOK_KERNEL_DOC_ROOT="$scratch/doc"
export OMARCHY_ZENBOOK_KERNEL_MODULES_ROOT="$scratch/modules"
export OMARCHY_ZENBOOK_CMDLINE_FILE="$scratch/cmdline"
export OMARCHY_ZENBOOK_WIREPLUMBER_DIR="$scratch/wireplumber.conf.d"
export OMARCHY_QUALCOMM_MODPROBE_DIR="$scratch/modprobe.d"
export OMARCHY_ZENBOOK_BOOT_HOOKS_DIR="$scratch/boot-hooks"
limine-entry-tool() {
  [[ $* == "--get-cmdline default" ]] || return 1
  printf '%s\n' "$(cat "$OMARCHY_ZENBOOK_CMDLINE_FILE")${staged_unlock:-}"
}
export -f limine-entry-tool

matching="$scratch/matching"
mkdir -p "$matching/proc/device-tree"
printf 'asus,zenbook-a16-ux3607oa\0qcom,glymur\0' >"$matching/proc/device-tree/compatible"
(
  omarchy-hw-aarch64-qualcomm() { return 0; }
  omarchy-hw-match() { return 1; }
  systemctl() { printf '%s\n' "$*" >>"$matching/systemctl.log"; }

  OMARCHY_PROC_ROOT="$matching/proc" \
    OMARCHY_ZENBOOK_MODULES_LOAD_DIR="$matching/modules-load.d" \
    OMARCHY_ZENBOOK_MKINITCPIO_DIR="$matching/mkinitcpio.conf.d" \
    OMARCHY_ZENBOOK_LIMINE_CONFIG_DIR="$matching/limine-entry-tool.d" \
    OMARCHY_ZENBOOK_SLEEP_CONFIG_DIR="$matching/sleep.conf.d" \
    source "$setup"
)

# Missing root must fail before any board files or services are changed.
(
  omarchy-hw-aarch64-qualcomm() { return 0; }
  omarchy-hw-match() { return 0; }
  systemctl() { fail "invalid root must not change services"; }
  echo quiet > "$scratch/invalid-cmdline"
  mkdir -p "$scratch/invalid-root"
  echo preserved > "$scratch/invalid-root/zenbook-a16.conf"
  for failure in rootless query; do
    if [[ $failure == "query" ]]; then
      echo "root=/dev/mapper/root rw" > "$scratch/invalid-cmdline"
      limine-entry-tool() { return 1; }
    fi
    if OMARCHY_ZENBOOK_CMDLINE_FILE="$scratch/invalid-cmdline" \
      OMARCHY_ZENBOOK_MODULES_LOAD_DIR="$scratch/invalid-root" \
      OMARCHY_ZENBOOK_MKINITCPIO_DIR="$scratch/invalid-root" \
      OMARCHY_ZENBOOK_LIMINE_CONFIG_DIR="$scratch/invalid-root" \
      OMARCHY_ZENBOOK_SLEEP_CONFIG_DIR="$scratch/invalid-root" \
      source "$setup"; then
      fail "A16 setup rejects an invalid shared command line: $failure"
    fi
  done
  [[ $(ls -A "$scratch/invalid-root") == "zenbook-a16.conf" ]] ||
    fail "A16 root refusal leaves board configuration untouched"
  [[ $(cat "$scratch/invalid-root/zenbook-a16.conf") == "preserved" ]] ||
    fail "A16 root refusal preserves the previous Limine drop-in"
)

grep -Fxq 'scmi-cpufreq' "$matching/modules-load.d/zenbook-a16.conf" ||
  fail "ASUS Zenbook A16 setup loads its SCMI CPU-frequency driver"
for setting in AllowSuspend AllowHibernation AllowSuspendThenHibernate AllowHybridSleep; do
  grep -Fxq "$setting=no" "$matching/sleep.conf.d/omarchy-sleep-disabled.conf" ||
    fail "ASUS Zenbook A16 blocks $setting until suspend is validated"
done
(
  firmware_root="$scratch/firmware"
  mkdir -p "$firmware_root/qcom" "$firmware_root/updates/qcom"
  touch "$firmware_root/qcom/gen70500_sqe.fw.zst" \
    "$firmware_root/qcom/gen70500_gmu.bin.xz" \
    "$firmware_root/qcom/gen80100_sqe.fw.zst" \
    "$firmware_root/qcom/gen80100_gmu.bin.xz"
  MODULES=() FILES=()
  OMARCHY_ZENBOOK_FIRMWARE_ROOT="$firmware_root" \
    source "$matching/mkinitcpio.conf.d/zenbook-a16-initramfs.conf"
  [[ ${MODULES[*]} == "hid-asus asus_glymur_ec? i2c-hid-of qrtr ps883x pmic_glink_altmode" ]] ||
    fail "the generated config loads the keyboard, EC, and display modules"
  (( ${#FILES[@]} == 4 )) || fail "GPU microcode is included without duplicating the board zap shader"
  [[ ${FILES[0]} == "$firmware_root/qcom/gen70500_sqe.fw.zst" ]] ||
    fail "zstd gen70500 display firmware is included"
  [[ ${FILES[1]} == "$firmware_root/qcom/gen70500_gmu.bin.xz" ]] ||
    fail "xz gen70500 display firmware is included"
  [[ ${FILES[2]} == "$firmware_root/qcom/gen80100_sqe.fw.zst" ]] ||
    fail "zstd gen80100 display firmware is included"
  [[ ${FILES[3]} == "$firmware_root/qcom/gen80100_gmu.bin.xz" ]] ||
    fail "xz gen80100 display firmware is included"
  touch "$firmware_root/updates/qcom/gen70500_sqe.fw"
  FILES=()
  OMARCHY_ZENBOOK_FIRMWARE_ROOT="$firmware_root" \
    source "$matching/mkinitcpio.conf.d/zenbook-a16-initramfs.conf"
  [[ ${FILES[0]} == "$firmware_root/updates/qcom/gen70500_sqe.fw" ]] ||
    fail "plain extracted firmware takes precedence over compressed packaged firmware"
)
(
  declare -A KERNEL_CMDLINE=([default]="root=/dev/mapper/root quiet splash")
  source "$matching/limine-entry-tool.d/zz-zenbook-a16-boot.conf"
  [[ ${KERNEL_CMDLINE[default]} == "root=/dev/mapper/root quiet splash" ]] ||
    fail "Zenbook A16 changes parameters for unrelated kernels"
  for kernel in linux-omarchy fallback; do
    for argument in console=tty0 plymouth.enable=0 systemd.show_status=true; do
      [[ " ${KERNEL_CMDLINE[$kernel]} " == *" $argument "* ]] ||
        fail "Zenbook A16 $kernel lacks $argument"
    done
    [[ " ${KERNEL_CMDLINE[$kernel]} " != *" cma="* ]] ||
      fail "Zenbook A16 overrides the board CMA reservation"
    [[ " ${KERNEL_CMDLINE[$kernel]} " != *" panic="* ]] ||
      fail "Zenbook A16 changes the kernel panic policy"
    [[ " ${KERNEL_CMDLINE[$kernel]} " != *" initcall_blacklist=simpledrm_platform_driver_init "* ]] ||
      fail "Zenbook A16 disables the early boot display"
    [[ ${KERNEL_CMDLINE[$kernel]} == "root=/dev/mapper/root rw "* ]] ||
      fail "Zenbook A16 loses the installer's root parameters"
  done
)
(
  [[ -x $OMARCHY_ZENBOOK_BOOT_HOOKS_DIR/20-zenbook-a16-cmdline ]] ||
    fail "A16 refresh hook runs in Limine's pre-build hook pipeline"
  for staged_unlock in ' cryptkey=rootfs:/etc/omarchy/provisioning.key' ''; do
    export staged_unlock
    bash "$OMARCHY_ZENBOOK_BOOT_HOOKS_DIR/20-zenbook-a16-cmdline"
    declare -A KERNEL_CMDLINE=()
    source "$matching/limine-entry-tool.d/zz-zenbook-a16-boot.conf"
    for kernel in linux-omarchy fallback; do
      if [[ -n $staged_unlock ]]; then
        [[ " ${KERNEL_CMDLINE[$kernel]} " == *"$staged_unlock "* ]] ||
          fail "A16 $kernel inherits the staged reset unlock key at rebuild time"
      else
        [[ ${KERNEL_CMDLINE[$kernel]} != *cryptkey=* ]] ||
          fail "A16 $kernel drops the staged unlock key after provisioning"
      fi
    done
  done
  cp "$matching/limine-entry-tool.d/zz-zenbook-a16-boot.conf" "$scratch/boot-before"
  limine-entry-tool() { echo 'quiet'; }
  export -f limine-entry-tool
  if bash "$OMARCHY_ZENBOOK_BOOT_HOOKS_DIR/20-zenbook-a16-cmdline"; then
    fail "A16 rejects a shared command line without root"
  fi
  cmp -s "$scratch/boot-before" "$matching/limine-entry-tool.d/zz-zenbook-a16-boot.conf" ||
    fail "A16 preserves boot settings when the shared command line is invalid"
  limine-entry-tool() { echo 'root=/dev/mapper/root rw'; }
  export -f limine-entry-tool
  chmod u-w "$matching/limine-entry-tool.d"
  status=0
  bash "$OMARCHY_ZENBOOK_BOOT_HOOKS_DIR/20-zenbook-a16-cmdline" || status=$?
  chmod u+w "$matching/limine-entry-tool.d"
  [[ $status == 100 ]] || fail "A16 stops the boot rebuild when configuration cannot be written"
  cmp -s "$scratch/boot-before" "$matching/limine-entry-tool.d/zz-zenbook-a16-boot.conf" ||
    fail "A16 preserves boot settings when configuration cannot be written"
)
grep -Fxq 'disable zenbook-a16-remoteprocs.service' "$matching/systemctl.log" ||
  fail "Zenbook A16 disables legacy late DSP startup"

nonmatching="$scratch/nonmatching"
mkdir -p "$nonmatching/proc/device-tree"
printf 'qcom,x1e80100\0hp,elitebook-ultra-g1q\0' >"$nonmatching/proc/device-tree/compatible"
(
  omarchy-hw-aarch64-qualcomm() { return 0; }
  omarchy-hw-match() { return 1; }
  systemctl() { fail "nonmatching Qualcomm hardware does not enable Zenbook services"; }

  OMARCHY_PROC_ROOT="$nonmatching/proc" \
    OMARCHY_ZENBOOK_MODULES_LOAD_DIR="$nonmatching/modules-load.d" \
    OMARCHY_ZENBOOK_MKINITCPIO_DIR="$nonmatching/mkinitcpio.conf.d" \
    OMARCHY_ZENBOOK_LIMINE_CONFIG_DIR="$nonmatching/limine-entry-tool.d" \
    OMARCHY_ZENBOOK_SLEEP_CONFIG_DIR="$nonmatching/sleep.conf.d" \
    source "$setup"
)

[[ ! -e $nonmatching/sleep.conf.d/omarchy-sleep-disabled.conf ]] ||
  fail "unrelated Qualcomm hardware keeps its sleep policy"
[[ ! -e $nonmatching/modules-load.d/zenbook-a16.conf ]] ||
  fail "nonmatching Qualcomm hardware does not get Zenbook CPU setup"
[[ ! -e $nonmatching/mkinitcpio.conf.d/zenbook-a16-initramfs.conf ]] ||
  fail "nonmatching Qualcomm hardware does not get Zenbook initramfs setup"
[[ ! -e $nonmatching/limine-entry-tool.d/zenbook-a16.conf ]] ||
  fail "nonmatching Qualcomm hardware does not get Zenbook boot parameters"
[[ ! -e $nonmatching/systemd/zenbook-a16-remoteprocs.service ]] ||
  fail "nonmatching Qualcomm hardware does not get Zenbook services"

(
  omarchy-hw-aarch64-qualcomm() { return 0; }
  omarchy-hw-match() { [[ $1 == "UX3607OA" ]]; }
  systemctl() { :; }
  OMARCHY_PROC_ROOT="$scratch/no-compatible/proc" \
    OMARCHY_ZENBOOK_MODULES_LOAD_DIR="$nonmatching/modules-load.d" \
    OMARCHY_ZENBOOK_MKINITCPIO_DIR="$nonmatching/mkinitcpio.conf.d" \
    OMARCHY_ZENBOOK_LIMINE_CONFIG_DIR="$nonmatching/limine-entry-tool.d" \
    OMARCHY_ZENBOOK_SLEEP_CONFIG_DIR="$nonmatching/sleep.conf.d" \
    source "$setup"
)
[[ -f $nonmatching/modules-load.d/zenbook-a16.conf ]] ||
  fail "ASUS DMI matching works without a device-tree compatible property"

pass "ASUS Zenbook A16 adds only its board-specific keyboard, EC, display, CPU and DSP setup"

# Exercise the shared model and family helpers together, not just stubbed gates.
run_gate_on() (
  name=$1 platform=$2 dmi_match=$3
  shift 3
  out="$scratch/gates/$name"
  fixture="$scratch/platforms/$name"
  mkdir -p "$out"
  fake_platform "$fixture" "$platform"
  if (( $# > 0 )); then
    mkdir -p "$fixture/proc/device-tree"
    printf '%s\0' "$@" >"$fixture/proc/device-tree/compatible"
  fi
  export OMARCHY_PROC_ROOT="$fixture/proc"
  export PATH="$fixture/bin:$ROOT/bin:$PATH"
  omarchy-hw-match() { [[ $dmi_match == "yes" && $1 == "UX3607OA" ]]; }
  systemctl() { printf '%s\n' "$*" >>"$out/systemctl.log"; }
  OMARCHY_ZENBOOK_MODULES_LOAD_DIR="$out/modules-load.d" \
    OMARCHY_ZENBOOK_MKINITCPIO_DIR="$out/mkinitcpio.conf.d" \
    OMARCHY_ZENBOOK_LIMINE_CONFIG_DIR="$out/limine-entry-tool.d" \
    OMARCHY_ZENBOOK_SLEEP_CONFIG_DIR="$out/sleep.conf.d" \
    source "$setup"
)

for compatible in asus,zenbook-a16-ux3607oa asus,ux3607oa ASUS,UX3607OA; do
  run_gate_on "$compatible" aarch64-qualcomm no "$compatible" qcom,glymur
  [[ -f $scratch/gates/$compatible/sleep.conf.d/omarchy-sleep-disabled.conf ]] ||
    fail "Zenbook A16 accepts both device-tree aliases, case-insensitively"
done
run_gate_on dmi aarch64-qualcomm yes
[[ -f $scratch/gates/dmi/sleep.conf.d/omarchy-sleep-disabled.conf ]] ||
  fail "Zenbook A16 accepts its DMI model on a Qualcomm platform"
for compatible in qcom,glymur asus,ux3607o asus,ux3607oa-other other,zenbook-a16; do
  run_gate_on "$compatible" aarch64-qualcomm no "$compatible" qcom,glymur
  [[ -z $(ls -A "$scratch/gates/$compatible") ]] ||
    fail "Zenbook A16 rejects other Glymur models and partial compatible strings"
done
for platform in aarch64 aarch64-apple x86; do
  run_gate_on "$platform" "$platform" yes
  [[ -z $(ls -A "$scratch/gates/$platform") ]] ||
    fail "the Zenbook DMI name on $platform gets no board setup"
done
pass "Zenbook A16 setup follows the shared device-tree and platform helpers"
