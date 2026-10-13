#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/microsoft/surface-pro-11.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

bash -n "$setup" || fail "Surface Pro 11 hardware script has valid syntax"
grep -Fxq 'run_logged "$OMARCHY_INSTALL/hardware/microsoft/surface-pro-11.sh"' "$ROOT/install/hardware/all.sh" ||
  fail "Surface Pro 11 setup runs with the other hardware scripts"

require_platform_fixtures "the Surface Pro 11 setup"

run_setup() (
  set -eE
  local dir=$1
  PATH="$ROOT/bin:$PATH"
  omarchy-hw-aarch64-qualcomm() { return 0; }
  omarchy-pkg-add() {
    printf 'add %s\n' "$*" >>"$dir/packages.log"
    [[ ! -e $dir/pkg-add-fails ]]
  }
  omarchy-pkg-drop() { printf 'drop %s\n' "$*" >>"$dir/packages.log"; }
  surface-pro-11-sensors-extract() { printf 'extract\n' >>"$dir/packages.log"; return 1; }
  systemctl() { printf 'systemctl %s\n' "$*" >>"$dir/packages.log"; }
  pacman() {
    case $1 in
      -Q) [[ $2 == linux-aarch64 || ( $2 == linux-aarch64-headers && -e $dir/headers ) ]] ;;
      *) fail "unexpected pacman call: $*" ;;
    esac
  }

  OMARCHY_PROC_ROOT="$dir/proc" \
    OMARCHY_SURFACE_PRO11_MKINITCPIO_DIR="$dir/mkinitcpio.conf.d" \
    OMARCHY_SURFACE_PRO11_LIMINE_CONFIG_DIR="$dir/limine-entry-tool.d" \
    OMARCHY_SURFACE_PRO11_UKI_CONFIG="$dir/kernel/uki.conf" \
    source "$setup"
)

matching="$scratch/matching"
mkdir -p "$matching/kernel" "$matching/mkinitcpio.conf.d"
printf 'MODULES=(pinctrl_tigerlake intel_lpss_pci 8250_dw)\n' >"$matching/mkinitcpio.conf.d/surface_device_modules.conf"
mkdir -p "$matching/proc/device-tree"
printf 'microsoft,denali-oled\0microsoft,denali\0qcom,x1e80100\0' >"$matching/proc/device-tree/compatible"
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

expected_packages=$'add linux-omarchy-n1x surface-pro-11-support\ndrop linux-aarch64 linux-aarch64-headers\nadd pipewire-libcamera\nadd iptsd surface-pro-11-sensors\nextract\nsystemctl enable surface-pro-11-sensors.service'
[[ $(head -n6 "$matching/packages.log") == "$expected_packages" ]] ||
  fail "Surface Pro 11 setup replaces the stock kernel first, then adds its hardware support and enables the light sensor even without Windows"
[[ ! -e $matching/mkinitcpio.conf.d/surface_device_modules.conf ]] ||
  fail "a stale Intel Surface module file cannot reset the Surface Pro 11's early modules"

grep -Fxq 'Cmdline=@/etc/kernel/cmdline' "$matching/kernel/uki.conf" ||
  fail "unrelated UKI settings are preserved"
! grep -q 'DeviceTreeAuto' "$matching/kernel/uki.conf" ||
  fail "the stock kernel's device-tree list is removed with the stock kernel"
[[ $(grep -c '^DeviceTree=/boot/dtbs/linux-omarchy-n1x/qcom/x1e80100-microsoft-denali-oled.dtb$' "$matching/kernel/uki.conf") == 1 ]] ||
  fail "the UKI embeds the Surface Pro 11 device tree from Omarchy's kernel exactly once across reruns"
[[ $(find "$matching/kernel" -type f | wc -l) == 1 ]] ||
  fail "the kept UKI configuration is removed once the kernel installs"
grep -Eq '(^|[( ])videocc_sm8550\?( |$)' "$matching/mkinitcpio.conf.d/surface-pro-11-initramfs.conf" ||
  fail "the video clock controller the stock kernel lacks is optional in the early-boot list"

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

[[ ! -e $matching/limine-entry-tool.d/zz-surface-pro-11.conf ]] ||
  fail "the Surface Pro 11 leaves the boot order to Omarchy's defaults"
stale="$scratch/stale"
mkdir -p "$stale/limine-entry-tool.d"
mkdir -p "$stale/proc/device-tree" && cp "$matching/proc/device-tree/compatible" "$stale/proc/device-tree/compatible"
printf 'BOOT_ORDER="linux-sp11*, *fallback, Snapshots"\n' >"$stale/limine-entry-tool.d/zz-surface-pro-11.conf"
run_setup "$stale" >/dev/null
[[ ! -e $stale/limine-entry-tool.d/zz-surface-pro-11.conf ]] ||
  fail "an earlier linux-sp11 boot order is removed"

failing="$scratch/failing"
mkdir -p "$failing"
mkdir -p "$failing/proc/device-tree" "$failing/kernel" && cp "$matching/proc/device-tree/compatible" "$failing/proc/device-tree/compatible"
printf '[UKI]\nDeviceTreeAuto=/boot/dtbs/qcom/x1e80100-microsoft-denali-oled.dtb\n' >"$failing/kernel/uki.conf"
cp -p "$failing/kernel/uki.conf" "$scratch/failing-uki.conf"
touch "$failing/pkg-add-fails"
# Hardware scripts run with errexit, which an `if` would suspend.
set +e
run_setup "$failing" >/dev/null 2>&1
status=$?
set -e
(( status != 0 )) || fail "a failed kernel install stops the setup"
! grep -q '^drop' "$failing/packages.log" ||
  fail "the stock kernel stays installed when Omarchy's kernel fails to install"
cmp -s "$scratch/failing-uki.conf" "$failing/kernel/uki.conf" ||
  fail "a failed kernel install restores the stock kernel's UKI configuration"
[[ $(find "$failing/kernel" -type f | wc -l) == 1 ]] ||
  fail "a failed kernel install leaves no temporary UKI configuration behind"

failing_fresh="$scratch/failing-fresh"
mkdir -p "$failing_fresh/proc/device-tree" && cp "$matching/proc/device-tree/compatible" "$failing_fresh/proc/device-tree/compatible"
touch "$failing_fresh/pkg-add-fails"
set +e
run_setup "$failing_fresh" >/dev/null 2>&1
status=$?
set -e
(( status != 0 )) && [[ ! -e $failing_fresh/kernel/uki.conf ]] ||
  fail "a failed kernel install removes a UKI configuration it created"

headers="$scratch/headers"
mkdir -p "$headers"
mkdir -p "$headers/proc/device-tree" && cp "$matching/proc/device-tree/compatible" "$headers/proc/device-tree/compatible"
touch "$headers/headers"
run_setup "$headers" >/dev/null
grep -Fxq 'add linux-omarchy-n1x linux-omarchy-n1x-headers surface-pro-11-support' "$headers/packages.log" ||
  fail "kernel headers are replaced along with the stock kernel"

fresh="$scratch/fresh"
mkdir -p "$fresh"
mkdir -p "$fresh/proc/device-tree" && cp "$matching/proc/device-tree/compatible" "$fresh/proc/device-tree/compatible"
run_setup "$fresh" >/dev/null
grep -Fxq 'DeviceTree=/boot/dtbs/linux-omarchy-n1x/qcom/x1e80100-microsoft-denali-oled.dtb' "$fresh/kernel/uki.conf" ||
  fail "a missing UKI configuration is created with the Surface device tree"

for model in 'microsoft,denali\0qcom,x1p64100' 'lenovo,yoga-slim7x\0qcom,x1e80100'; do
  other="$scratch/other"
  rm -rf "$other"
  mkdir -p "$other"
  mkdir -p "$other/proc/device-tree"
  printf '%b\0' "$model" >"$other/proc/device-tree/compatible"
  run_setup "$other" >/dev/null
  [[ ! -e $other/packages.log && ! -e $other/mkinitcpio.conf.d && ! -e $other/limine-entry-tool.d && ! -e $other/kernel ]] ||
    fail "untested Denali variants and other boards are left unchanged"
done

pass "Surface Pro 11 setup configures only the tested OLED model"
