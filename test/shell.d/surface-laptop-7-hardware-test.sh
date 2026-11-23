#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/microsoft/surface-laptop-7.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

bash -n "$setup" || fail "Surface Laptop 7 hardware script has valid syntax"

require_platform_fixtures "the Surface Laptop 7 setup"

run_setup() (
  set -eE
  local dir=$1
  PATH="$ROOT/bin:$PATH"
  omarchy-hw-aarch64-qualcomm() { return 0; }
  omarchy-pkg-add() { printf 'add %s\n' "$*" >>"$dir/packages.log"; }

  OMARCHY_PROC_ROOT="$dir/proc" \
    OMARCHY_SURFACE_LAPTOP7_MKINITCPIO_DIR="$dir/mkinitcpio.conf.d" \
    source "$setup"
)

compatible() {
  mkdir -p "$1/proc/device-tree"
  printf '%b' "$2" >"$1/proc/device-tree/compatible"
}

matching="$scratch/matching"
compatible "$matching" 'microsoft,romulus15\0qcom,x1e80100\0'
run_setup "$matching" >/dev/null
[[ $(<"$matching/packages.log") == 'add microsoft-surface-snapdragon-addresses iptsd microsoft-surface-laptop-7-support' ]] ||
  fail "Surface Laptop 7 15\" setup adds its Wi-Fi and Bluetooth addresses, iptsd and its support package"

(
  firmware_root="$scratch/firmware"
  mkdir -p "$firmware_root/qcom" "$firmware_root/updates/qcom"
  touch "$firmware_root/qcom/gen70500_sqe.fw.zst" "$firmware_root/updates/qcom/gen70500_sqe.fw"
  MODULES=() FILES=()
  OMARCHY_SURFACE_LAPTOP7_FIRMWARE_ROOT="$firmware_root" \
    source "$matching/mkinitcpio.conf.d/surface-laptop-7-initramfs.conf"

  for module in "${MODULES[@]}"; do
    [[ $module == *\? ]] || fail "$module is optional, so a kernel without it still builds its image"
  done

  for module in pwm_bl leds_qcom_lpg surface_aggregator surface_aggregator_registry surface_hid; do
    [[ " ${MODULES[*]} " == *" $module? "* ]] ||
      fail "$module loads early, for the backlight and the keyboard at disk unlock"
  done

  [[ ${FILES[*]} == "$firmware_root/updates/qcom/gen70500_sqe.fw" ]] ||
    fail "early firmware prefers extracted copies and skips what is missing"
)

# The 13.8" model gets its keyboard at disk unlock, its addresses and iptsd
smaller="$scratch/smaller"
compatible "$smaller" 'microsoft,romulus13\0qcom,x1e80100\0'
run_setup "$smaller" >/dev/null
[[ $(<"$smaller/packages.log") == 'add microsoft-surface-snapdragon-addresses iptsd microsoft-surface-laptop-7-support' ]] ||
  fail "Surface Laptop 7 13.8\" setup adds its Wi-Fi and Bluetooth addresses, iptsd and its support package"
(
  MODULES=() FILES=()
  source "$smaller/mkinitcpio.conf.d/surface-laptop-7-initramfs.conf"
  for module in "${MODULES[@]}"; do
    [[ $module == surface_*\? ]] || fail "$module is one of the keyboard's drivers and optional"
  done
  (( ${#MODULES[@]} > 0 && ${#FILES[@]} == 0 )) ||
    fail "Surface Laptop 7 13.8\" setup loads the keyboard early and leaves the screen to the Snapdragon X setup"
)

other="$scratch/other"
compatible "$other" 'lenovo,yoga-slim7x\0qcom,x1e80100\0'
run_setup "$other" >/dev/null
[[ ! -e $other/packages.log && ! -e $other/mkinitcpio.conf.d ]] ||
  fail "another Snapdragon X laptop is left alone"

pass "Surface Laptop 7 setup configures the 15\" and 13.8\" models"
