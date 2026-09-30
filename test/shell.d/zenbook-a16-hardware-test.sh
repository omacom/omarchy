#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/asus/zenbook-a16.sh"
starter="$ROOT/install/hardware/asus/start-zenbook-a16-remoteprocs.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

for script in "$setup" "$starter"; do
  bash -n "$script" || fail "ASUS Zenbook A16 hardware scripts have valid syntax"
done

matching="$scratch/matching"
mkdir -p "$matching"
printf 'asus,zenbook-a16-ux3607oa\0qcom,glymur\0' >"$matching/compatible"
(
  omarchy-hw-qualcomm-soc() { return 0; }
  omarchy-hw-match() { return 1; }
  systemctl() { printf '%s\n' "$*" >>"$matching/systemctl.log"; }
  limine-mkinitcpio() { printf '%s\n' rebuild >>"$matching/boot-rebuild.log"; }

  OMARCHY_ZENBOOK_COMPATIBLE_PATH="$matching/compatible" \
    OMARCHY_ZENBOOK_MODULES_LOAD_DIR="$matching/modules-load.d" \
    OMARCHY_ZENBOOK_MKINITCPIO_DIR="$matching/mkinitcpio.conf.d" \
    OMARCHY_ZENBOOK_LIMINE_CONFIG_DIR="$matching/limine-entry-tool.d" \
    OMARCHY_ZENBOOK_SYSTEMD_DIR="$matching/systemd" \
    source "$setup"
)

grep -Fxq 'scmi-cpufreq' "$matching/modules-load.d/zenbook-a16.conf" ||
  fail "ASUS Zenbook A16 setup loads its SCMI CPU-frequency driver"
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
  source "$matching/limine-entry-tool.d/zenbook-a16.conf"
  [[ " ${KERNEL_CMDLINE[default]} " == *" console=tty0 "* ]] ||
    fail "Zenbook A16 uses the laptop console for graphical disk unlock"
  [[ " ${KERNEL_CMDLINE[default]} " == *" glymur_pci_skip=5 "* ]] ||
    fail "Zenbook A16 skips suspend-breaking PCI bridge 5"
  [[ " ${KERNEL_CMDLINE[default]} " == *" cma=128M "* ]] ||
    fail "Zenbook A16 allocates sufficient CMA memory"
  [[ " ${KERNEL_CMDLINE[default]} " == *" systemd.mask=dev-tpm0.device "* ]] ||
    fail "Zenbook A16 masks lockup-prone TPM device"
  [[ " ${KERNEL_CMDLINE[default]} " != *" initcall_blacklist=simpledrm_platform_driver_init "* ]] ||
    fail "Zenbook A16 leaves simpledrm enabled for early boot display"
  [[ " ${KERNEL_CMDLINE[default]} " == *" plymouth.enable=0 "* ]] ||
    fail "Zenbook A16 disables plymouth to avoid blanking early console"
  [[ " ${KERNEL_CMDLINE[default]} " == *" systemd.show_status=true "* ]] ||
    fail "Zenbook A16 enables visible systemd status on the console"
  [[ ${KERNEL_CMDLINE[default]} == "root=/dev/mapper/root quiet splash "* ]] ||
    fail "Zenbook A16 preserves the existing boot parameters"
)
grep -Fq 'ConditionPathExists=!/etc/modprobe.d/qualcomm-adsp-nofw.conf' \
  "$matching/systemd/zenbook-a16-remoteprocs.service" ||
  fail "Zenbook A16 skips DSP startup when the generic firmware leaf blacklists it"
grep -Fxq 'enable zenbook-a16-remoteprocs.service' "$matching/systemctl.log" ||
  fail "Zenbook A16 enables its remote processor service"
grep -Fxq 'rebuild' "$matching/boot-rebuild.log" ||
  fail "Zenbook A16 rebuilds initramfs and Limine entries after installing board configuration"

nonmatching="$scratch/nonmatching"
mkdir -p "$nonmatching"
printf 'qcom,x1e80100\0hp,elitebook-ultra-g1q\0' >"$nonmatching/compatible"
(
  omarchy-hw-qualcomm-soc() { return 0; }
  omarchy-hw-match() { return 1; }
  systemctl() { fail "nonmatching Qualcomm hardware does not enable Zenbook services"; }
  limine-mkinitcpio() { fail "nonmatching Qualcomm hardware does not rebuild boot artifacts"; }

  OMARCHY_ZENBOOK_COMPATIBLE_PATH="$nonmatching/compatible" \
    OMARCHY_ZENBOOK_MODULES_LOAD_DIR="$nonmatching/modules-load.d" \
    OMARCHY_ZENBOOK_MKINITCPIO_DIR="$nonmatching/mkinitcpio.conf.d" \
    OMARCHY_ZENBOOK_LIMINE_CONFIG_DIR="$nonmatching/limine-entry-tool.d" \
    OMARCHY_ZENBOOK_SYSTEMD_DIR="$nonmatching/systemd" \
    source "$setup"
)

[[ ! -e $nonmatching/modules-load.d/zenbook-a16.conf ]] ||
  fail "nonmatching Qualcomm hardware does not get Zenbook CPU setup"
[[ ! -e $nonmatching/mkinitcpio.conf.d/zenbook-a16-initramfs.conf ]] ||
  fail "nonmatching Qualcomm hardware does not get Zenbook initramfs setup"
[[ ! -e $nonmatching/limine-entry-tool.d/zenbook-a16.conf ]] ||
  fail "nonmatching Qualcomm hardware does not get Zenbook boot parameters"
[[ ! -e $nonmatching/systemd/zenbook-a16-remoteprocs.service ]] ||
  fail "nonmatching Qualcomm hardware does not get Zenbook services"

(
  omarchy-hw-qualcomm-soc() { return 0; }
  omarchy-hw-match() { [[ $1 == "UX3607OA" ]]; }
  systemctl() { :; }
  limine-mkinitcpio() { :; }
  OMARCHY_ZENBOOK_COMPATIBLE_PATH="$scratch/no-compatible" \
    OMARCHY_ZENBOOK_MODULES_LOAD_DIR="$nonmatching/modules-load.d" \
    OMARCHY_ZENBOOK_MKINITCPIO_DIR="$nonmatching/mkinitcpio.conf.d" \
    OMARCHY_ZENBOOK_LIMINE_CONFIG_DIR="$nonmatching/limine-entry-tool.d" \
    OMARCHY_ZENBOOK_SYSTEMD_DIR="$nonmatching/systemd" \
    source "$setup"
)
[[ -f $nonmatching/modules-load.d/zenbook-a16.conf ]] ||
  fail "ASUS DMI matching works without a device-tree compatible property"

remoteprocs="$scratch/remoteproc"
mkdir -p "$remoteprocs/remoteproc0" "$remoteprocs/remoteproc1" "$remoteprocs/remoteproc2"
printf 'qcom/glymur/adsp.mbn\n' >"$remoteprocs/remoteproc0/firmware"
printf 'offline\n' >"$remoteprocs/remoteproc0/state"
printf 'qcom/glymur/cdsp.mbn\n' >"$remoteprocs/remoteproc1/firmware"
printf 'offline\n' >"$remoteprocs/remoteproc1/state"
printf 'unrelated.mbn\n' >"$remoteprocs/remoteproc2/firmware"
printf 'offline\n' >"$remoteprocs/remoteproc2/state"

OMARCHY_ZENBOOK_REMOTEPROC_ROOT="$remoteprocs" \
  OMARCHY_ZENBOOK_REMOTEPROC_ATTEMPTS=1 \
  OMARCHY_ZENBOOK_REMOTEPROC_SLEEP=0 \
  bash "$starter"

[[ $(<"$remoteprocs/remoteproc0/state") == start ]] ||
  fail "Zenbook A16 helper starts the audio DSP by firmware identity"
[[ $(<"$remoteprocs/remoteproc1/state") == start ]] ||
  fail "Zenbook A16 helper starts the compute DSP by firmware identity"
[[ $(<"$remoteprocs/remoteproc2/state") == offline ]] ||
  fail "Zenbook A16 helper leaves unrelated remote processors alone"

run_starter() {
  OMARCHY_ZENBOOK_REMOTEPROC_ROOT="$remoteprocs" \
    OMARCHY_ZENBOOK_REMOTEPROC_ATTEMPTS=1 \
    OMARCHY_ZENBOOK_REMOTEPROC_SLEEP=0 \
    bash "$starter"
}
printf 'running\n' >"$remoteprocs/remoteproc0/state"
printf 'running\n' >"$remoteprocs/remoteproc1/state"
run_starter
[[ $(<"$remoteprocs/remoteproc0/state") == running ]] || fail "running ADSP is not restarted"
[[ $(<"$remoteprocs/remoteproc1/state") == running ]] || fail "running CDSP is not restarted"

printf 'unrelated.mbn\n' >"$remoteprocs/remoteproc0/firmware"
if run_starter; then fail "missing ADSP must time out, even when CDSP is running"; fi
printf 'qcom/glymur/adsp.mbn\n' >"$remoteprocs/remoteproc0/firmware"
printf 'running\n' >"$remoteprocs/remoteproc0/state"
printf 'unrelated.mbn\n' >"$remoteprocs/remoteproc1/firmware"
if run_starter; then fail "missing CDSP must time out, even when ADSP is running"; fi
printf 'qcom/glymur/cdsp.mbn\n' >"$remoteprocs/remoteproc1/firmware"
printf 'offline\n' >"$remoteprocs/remoteproc1/state"
(
  printf() {
    [[ $1 != "start\n" ]] || return 1
    # shellcheck disable=SC2059
    builtin printf "$@"
  }
  export -f printf
  if run_starter; then fail "a failed CDSP start must be reported"; fi
)

printf 'qcom/glymur/adsp.mbn\n' >"$remoteprocs/remoteproc0/firmware"
printf 'offline\n' >"$remoteprocs/remoteproc0/state"
printf 'running\n' >"$remoteprocs/remoteproc1/state"
(
  printf() {
    [[ $1 != "start\n" ]] || return 1
    # shellcheck disable=SC2059
    builtin printf "$@"
  }
  export -f printf
  if run_starter; then fail "a failed ADSP start must be reported"; fi
)

pass "ASUS Zenbook A16 adds only its board-specific keyboard, EC, display, CPU and DSP setup"
