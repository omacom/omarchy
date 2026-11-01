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

# The installer is offline, so the ISO's mirror must carry what the setup adds.
for package in surface-pro-11-support iptsd surface-pro-11-sensors; do
  grep -Fxq "$package" "$ROOT/install/omarchy-other.packages" ||
    fail "the ISO can supply $package offline"
done

run_setup() (
  set -eE
  local dir=$1
  PATH="$ROOT/bin:$PATH"
  omarchy-hw-aarch64-qualcomm() { return 0; }
  omarchy-pkg-add() { printf 'add %s\n' "$*" >>"$dir/packages.log"; }
  surface-pro-11-sensors-extract() { printf 'extract\n' >>"$dir/packages.log"; return 1; }
  systemctl() { printf 'systemctl %s\n' "$*" >>"$dir/packages.log"; }

  OMARCHY_PROC_ROOT="$dir/proc" \
    OMARCHY_SURFACE_PRO11_MKINITCPIO_DIR="$dir/mkinitcpio.conf.d" \
    OMARCHY_SURFACE_PRO11_UKI_CONFIG="$dir/kernel/uki.conf" \
    OMARCHY_QUALCOMM_DTB_ROOT="$dir/dtbs" \
    source "$setup"
)

surface_pro11() {
  local dir=$1
  mkdir -p "$dir/proc/device-tree" "$dir/dtbs/linux-omarchy/qcom"
  printf 'microsoft,denali-oled\0microsoft,denali\0qcom,x1e80100\0' >"$dir/proc/device-tree/compatible"
  : >"$dir/dtbs/linux-omarchy/qcom/x1e80100-microsoft-denali-oled.dtb"
}

matching="$scratch/matching"
surface_pro11 "$matching"
mkdir -p "$matching/kernel" "$matching/mkinitcpio.conf.d"
printf 'MODULES=(pinctrl_tigerlake intel_lpss_pci 8250_dw)\n' >"$matching/mkinitcpio.conf.d/surface_device_modules.conf"
cat >"$matching/kernel/uki.conf" <<'CONF'
[UKI]
Cmdline=@/etc/kernel/cmdline
# BEGIN OMARCHY QUALCOMM DEVICE TREES
[UKI]
DeviceTreeAuto=/boot/dtbs/linux-omarchy/qcom/x1e80100-microsoft-denali-oled.dtb /boot/dtbs/linux-omarchy/qcom/x1e80100-crd.dtb
# END OMARCHY QUALCOMM DEVICE TREES
CONF
run_setup "$matching" >/dev/null
run_setup "$matching" >/dev/null

expected_packages=$'add surface-pro-11-support iptsd surface-pro-11-sensors\nextract\nsystemctl enable surface-pro-11-sensors.service'
[[ $(head -n3 "$matching/packages.log") == "$expected_packages" ]] ||
  fail "Surface Pro 11 setup adds its hardware support and enables the light sensor even without Windows"
[[ ! -e $matching/mkinitcpio.conf.d/surface_device_modules.conf ]] ||
  fail "a stale Intel Surface module file cannot reset the Surface Pro 11's early modules"

grep -Fxq 'Cmdline=@/etc/kernel/cmdline' "$matching/kernel/uki.conf" ||
  fail "unrelated UKI settings are preserved"
! grep -q 'DeviceTreeAuto' "$matching/kernel/uki.conf" ||
  fail "the shared device-tree list is replaced, since the Denali models share an SMBIOS identity"
(( $(grep -c "^DeviceTree=$matching/dtbs/linux-omarchy/qcom/x1e80100-microsoft-denali-oled.dtb\$" "$matching/kernel/uki.conf") == 1 )) ||
  fail "the UKI embeds the OLED model's device tree exactly once across reruns"
(( $(find "$matching/kernel" -type f | wc -l) == 1 )) ||
  fail "no temporary UKI configuration is left behind"

request="$scratch/boot-rebuild"
(export OMARCHY_IMAGE_BOOT_REBUILD="$request" && run_setup "$matching" >/dev/null)
[[ ! -e $request ]] ||
  fail "an unchanged UKI configuration asks for no rebuild"
printf '# BEGIN OMARCHY QUALCOMM DEVICE TREES\n[UKI]\nDeviceTreeAuto=/boot/dtbs/qcom/x1e80100-crd.dtb\n# END OMARCHY QUALCOMM DEVICE TREES\n' >>"$matching/kernel/uki.conf"
(export OMARCHY_IMAGE_BOOT_REBUILD="$request" && run_setup "$matching" >/dev/null)
[[ -e $request ]] ||
  fail "a changed UKI configuration asks an image's first boot for the rebuild"

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
    [[ $module == *\? ]] ||
      fail "$module is optional, so a kernel without it still builds its image"
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

fresh="$scratch/fresh"
surface_pro11 "$fresh"
run_setup "$fresh" >/dev/null
grep -Fxq "DeviceTree=$fresh/dtbs/linux-omarchy/qcom/x1e80100-microsoft-denali-oled.dtb" "$fresh/kernel/uki.conf" ||
  fail "a missing UKI configuration is created with the OLED model's device tree"
[[ $(stat -c %a "$fresh/kernel/uki.conf") == "644" ]] ||
  fail "a created UKI configuration is readable like the one dtb-uki.sh writes"

no_dtb="$scratch/no-dtb"
surface_pro11 "$no_dtb"
rm "$no_dtb/dtbs/linux-omarchy/qcom/x1e80100-microsoft-denali-oled.dtb"
mkdir -p "$no_dtb/kernel"
printf '[UKI]\nDeviceTreeAuto=/boot/dtbs/qcom/x1e80100-microsoft-denali-oled.dtb\n' >"$no_dtb/kernel/uki.conf"
cp -p "$no_dtb/kernel/uki.conf" "$scratch/no-dtb-uki.conf"
run_setup "$no_dtb" >/dev/null
cmp -s "$scratch/no-dtb-uki.conf" "$no_dtb/kernel/uki.conf" ||
  fail "without Omarchy's kernel the device-tree list is left as it is"
grep -Fxq 'add surface-pro-11-support iptsd surface-pro-11-sensors' "$no_dtb/packages.log" ||
  fail "the hardware support is added even before Omarchy's kernel is installed"

stale_pin="$scratch/stale-pin"
surface_pro11 "$stale_pin"
run_setup "$stale_pin" >/dev/null
printf '# BEGIN OMARCHY QUALCOMM DEVICE TREES\n[UKI]\nDeviceTreeAuto=/boot/dtbs/qcom/x1e80100-crd.dtb\n# END OMARCHY QUALCOMM DEVICE TREES\n' >>"$stale_pin/kernel/uki.conf"
rm -r "$stale_pin/dtbs/linux-omarchy"
run_setup "$stale_pin" >/dev/null
! grep -q '^DeviceTree=' "$stale_pin/kernel/uki.conf" ||
  fail "a pin to a device tree that is gone is removed, so the UKI still builds"
grep -Fxq 'DeviceTreeAuto=/boot/dtbs/qcom/x1e80100-crd.dtb' "$stale_pin/kernel/uki.conf" ||
  fail "without Omarchy's kernel the device-tree list dtb-uki.sh wrote is kept"

renamed="$scratch/renamed"
surface_pro11 "$renamed"
mv "$renamed/dtbs/linux-omarchy" "$renamed/dtbs/linux-omarchy-aarch64"
run_setup "$renamed" >/dev/null
grep -Fxq "DeviceTree=$renamed/dtbs/linux-omarchy-aarch64/qcom/x1e80100-microsoft-denali-oled.dtb" "$renamed/kernel/uki.conf" ||
  fail "the device tree is found under any linux-omarchy package directory, as dtb-uki.sh finds it"

for model in 'microsoft,denali\0qcom,x1p64100' 'lenovo,yoga-slim7x\0qcom,x1e80100'; do
  other="$scratch/other"
  rm -rf "$other"
  surface_pro11 "$other"
  printf '%b\0' "$model" >"$other/proc/device-tree/compatible"
  run_setup "$other" >/dev/null
  [[ ! -e $other/packages.log && ! -e $other/mkinitcpio.conf.d && ! -e $other/kernel ]] ||
    fail "untested Denali variants and other boards are left unchanged"
done

pass "Surface Pro 11 setup configures only the tested OLED model"
