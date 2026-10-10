#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/microsoft/surface-pro-11.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

bash -n "$setup" || fail "Surface Pro 11 hardware script has valid syntax"
grep -Fxq 'run_logged "$OMARCHY_INSTALL/hardware/microsoft/surface-pro-11.sh"' "$ROOT/install/hardware/all.sh" ||
  fail "Surface Pro 11 setup runs with the other hardware scripts"

run_setup() (
  set -eE
  local dir=$1
  omarchy-hw-aarch64-qualcomm() { return 0; }
  omarchy-pkg-add() {
    printf 'add %s\n' "$*" >>"$dir/packages.log"
    [[ ! -e $dir/pkg-add-fails ]]
  }
  surface-pro-11-sensors-extract() { printf 'extract\n' >>"$dir/packages.log"; return 1; }
  systemctl() { printf 'systemctl %s\n' "$*" >>"$dir/packages.log"; }
  pacman() {
    case $1 in
      -Q) [[ $2 == linux-aarch64 || ( $2 == linux-aarch64-headers && -e $dir/headers ) ]] ;;
      -Rdd) printf 'remove %s\n' "${*: -1}" >>"$dir/packages.log" ;;
      -S) printf 'replace %s\n' "$*" >>"$dir/packages.log" ;;
      *) fail "unexpected pacman call: $*" ;;
    esac
  }

  OMARCHY_SURFACE_PRO11_COMPATIBLE_PATH="$dir/compatible" \
    OMARCHY_SURFACE_PRO11_MKINITCPIO_DIR="$dir/mkinitcpio.conf.d" \
    OMARCHY_SURFACE_PRO11_LIMINE_CONFIG_DIR="$dir/limine-entry-tool.d" \
    OMARCHY_SURFACE_PRO11_UKI_CONFIG="$dir/kernel/uki.conf" \
    source "$setup"
)

matching="$scratch/matching"
mkdir -p "$matching/kernel" "$matching/mkinitcpio.conf.d"
printf 'MODULES=(pinctrl_tigerlake intel_lpss_pci 8250_dw)\n' >"$matching/mkinitcpio.conf.d/surface_device_modules.conf"
printf 'microsoft,denali-oled\0microsoft,denali\0qcom,x1e80100\0' >"$matching/compatible"
cat >"$matching/kernel/uki.conf" <<'CONF'
[UKI]
Cmdline=@/etc/kernel/cmdline
# BEGIN OMARCHY QUALCOMM DEVICE TREES
[UKI]
DeviceTreeAuto=/boot/dtbs/qcom/x1e80100-microsoft-denali-oled.dtb /boot/dtbs/qcom/x1e80100-crd.dtb
# END OMARCHY QUALCOMM DEVICE TREES
CONF
run_setup "$matching" >/dev/null
run_setup "$matching" >/dev/null

expected_packages=$'add linux-sp11 surface-pro-11-support\nremove linux-aarch64\nreplace -S --needed --noconfirm --ask 4 libcamera-surface-pro-11 pipewire-libcamera\nadd iptsd surface-pro-11-sensors power-profiles-daemon-surface-pro-11\nextract\nsystemctl enable surface-pro-11-sensors.service surface-pro-11-power-profile-cpufreq.service'
[[ $(head -n6 "$matching/packages.log") == "$expected_packages" ]] ||
  fail "Surface Pro 11 setup replaces the stock kernel first, then adds its hardware support and enables the light sensor even without Windows"
[[ ! -e $matching/mkinitcpio.conf.d/surface_device_modules.conf ]] ||
  fail "a stale Intel Surface module file cannot reset the Surface Pro 11's early modules"

grep -Fxq 'Cmdline=@/etc/kernel/cmdline' "$matching/kernel/uki.conf" ||
  fail "unrelated UKI settings are preserved"
! grep -q 'DeviceTreeAuto' "$matching/kernel/uki.conf" ||
  fail "the stock kernel's device-tree list is removed with the stock kernel"
[[ $(grep -c '^DeviceTree=/boot/dtbs/linux-sp11/qcom/x1e80100-microsoft-denali-oled.dtb$' "$matching/kernel/uki.conf") == 1 ]] ||
  fail "the UKI embeds the Surface kernel's device tree exactly once across reruns"

(
  firmware_root="$scratch/firmware"
  mkdir -p "$firmware_root/qcom/x1e80100" "$firmware_root/updates/ath12k/WCN7850/hw2.0"
  touch "$firmware_root/qcom/gen70500_sqe.fw.zst" \
    "$firmware_root/qcom/gen70500_gmu.bin.xz" \
    "$firmware_root/updates/ath12k/WCN7850/hw2.0/board.bin" \
    "$firmware_root/qcom/x1e80100/X1E80100-Microsoft-Surface-Pro-11-tplg.bin"
  MODULES=() FILES=()
  OMARCHY_SURFACE_PRO11_FIRMWARE_ROOT="$firmware_root" \
    source "$matching/mkinitcpio.conf.d/surface-pro-11-initramfs.conf"

  for module in msm dispcc_x1e80100 phy_qcom_edp panel_samsung_atna33xc20 ps883x qrtr qcom_pd_mapper pmic_glink_altmode surface_aggregator surface_hid; do
    [[ " ${MODULES[*]%\?} " == *" $module "* ]] ||
      fail "the Surface Pro 11 initramfs loads $module before disk unlock"
  done
  [[ " ${MODULES[*]} " != *" qcom_q6v5_pas "* ]] ||
    fail "the Surface Pro 11 initramfs leaves the DSP driver to the USB-root guard"
  for module in "${MODULES[@]}"; do
    [[ $module != surface_* || $module == *\? ]] ||
      fail "$module is optional, so a stock kernel without it still builds its image"
  done

  expected=(
    "$firmware_root/qcom/gen70500_sqe.fw.zst"
    "$firmware_root/qcom/gen70500_gmu.bin.xz"
    "$firmware_root/updates/ath12k/WCN7850/hw2.0/board.bin"
    "$firmware_root/qcom/x1e80100/X1E80100-Microsoft-Surface-Pro-11-tplg.bin"
  )
  [[ ${FILES[*]} == "${expected[*]}" ]] ||
    fail "early firmware prefers extracted copies and accepts compressed packaged firmware"

  rm "$firmware_root/qcom/x1e80100/X1E80100-Microsoft-Surface-Pro-11-tplg.bin"
  FILES=()
  OMARCHY_SURFACE_PRO11_FIRMWARE_ROOT="$firmware_root" \
    source "$matching/mkinitcpio.conf.d/surface-pro-11-initramfs.conf"
  (( ${#FILES[@]} == 3 )) || fail "missing optional firmware is skipped instead of breaking the build"
)

(
  BOOT_ORDER="*, *fallback, Snapshots"
  source "$matching/limine-entry-tool.d/zz-surface-pro-11.conf"
  [[ $BOOT_ORDER == "linux-sp11*, *fallback, Snapshots" ]] ||
    fail "Surface Pro 11 boots its kernel first"
)

failing="$scratch/failing"
mkdir -p "$failing"
cp "$matching/compatible" "$failing/compatible"
touch "$failing/pkg-add-fails"
# Hardware scripts run with errexit, which an `if` would suspend.
set +e
run_setup "$failing" >/dev/null 2>&1
status=$?
set -e
(( status != 0 )) || fail "a failed Surface kernel install stops the setup"
! grep -q '^remove' "$failing/packages.log" ||
  fail "the stock kernel stays installed when the Surface kernel fails to install"
grep -Fxq 'DeviceTree=/boot/dtbs/linux-sp11/qcom/x1e80100-microsoft-denali-oled.dtb' "$failing/kernel/uki.conf" ||
  fail "boot configuration is written before the kernel install"

headers="$scratch/headers"
mkdir -p "$headers"
cp "$matching/compatible" "$headers/compatible"
touch "$headers/headers"
run_setup "$headers" >/dev/null
grep -Fxq 'add linux-sp11 linux-sp11-headers surface-pro-11-support' "$headers/packages.log" ||
  fail "kernel headers are replaced along with the stock kernel"

fresh="$scratch/fresh"
mkdir -p "$fresh"
cp "$matching/compatible" "$fresh/compatible"
run_setup "$fresh" >/dev/null
grep -Fxq 'DeviceTree=/boot/dtbs/linux-sp11/qcom/x1e80100-microsoft-denali-oled.dtb' "$fresh/kernel/uki.conf" ||
  fail "a missing UKI configuration is created with the Surface device tree"

for model in 'microsoft,denali\0qcom,x1p64100' 'lenovo,yoga-slim7x\0qcom,x1e80100'; do
  other="$scratch/other"
  rm -rf "$other"
  mkdir -p "$other"
  printf '%b\0' "$model" >"$other/compatible"
  run_setup "$other" >/dev/null
  [[ ! -e $other/packages.log && ! -e $other/mkinitcpio.conf.d && ! -e $other/limine-entry-tool.d && ! -e $other/kernel ]] ||
    fail "untested Denali variants and other boards are left unchanged"
done

pass "Surface Pro 11 setup configures only the tested OLED model"
