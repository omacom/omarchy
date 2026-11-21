#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/qualcomm/hamoa-display.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

bash -n "$setup" || fail "Snapdragon X display script has valid syntax"

require_platform_fixtures "the Snapdragon X display setup"

run_setup() (
  set -eE
  local dir=$1
  PATH="$ROOT/bin:$PATH"
  omarchy-hw-aarch64-qualcomm() { return 0; }

  OMARCHY_PROC_ROOT="$dir/proc" \
    OMARCHY_QUALCOMM_MKINITCPIO_DIR="$dir/mkinitcpio.conf.d" \
    source "$setup"
)

compatible() {
  mkdir -p "$1/proc/device-tree"
  printf '%b' "$2" >"$1/proc/device-tree/compatible"
}

# One model of each SoC, a tree that names its own variant before the SoC, and
# a model no setup of its own covers
for matching in 'lenovo,yoga-slim7x\0qcom,x1e80100\0' 'asus,zenbook-a14-ux3407qa\0qcom,x1p42100\0' \
  'lenovo,thinkpad-t14s\0qcom,x1e78100\0qcom,x1e80100\0' 'microsoft,romulus13\0qcom,x1e80100\0'; do
  dir="$scratch/matching-${matching%%\\0*}"
  compatible "$dir" "$matching"
  run_setup "$dir" >/dev/null
  [[ -f $dir/mkinitcpio.conf.d/qualcomm-hamoa-display.conf ]] ||
    fail "${matching%%\\0*} gets the display chain in its boot image"
done

(
  firmware_root="$scratch/firmware"
  mkdir -p "$firmware_root/qcom" "$firmware_root/updates/qcom"
  touch "$firmware_root/qcom/gen70500_sqe.fw.zst" "$firmware_root/updates/qcom/gen70500_sqe.fw" "$firmware_root/qcom/gen71500_gmu.bin.xz"
  MODULES=() FILES=()
  OMARCHY_QUALCOMM_FIRMWARE_ROOT="$firmware_root" \
    source "$scratch/matching-lenovo,yoga-slim7x/mkinitcpio.conf.d/qualcomm-hamoa-display.conf"

  for module in "${MODULES[@]}"; do
    [[ $module == *\? ]] || fail "$module is optional, so a kernel or a model without it still builds its image"
  done

  [[ ${FILES[*]} == "$firmware_root/updates/qcom/gen70500_sqe.fw $firmware_root/qcom/gen71500_gmu.bin.xz" ]] ||
    fail "early firmware prefers extracted copies and skips what is missing"
)

# Snapdragon X2 has its own setup, and the older chips show their prompt
# through the firmware's screen
for other in 'qcom,glymur-crd\0qcom,glymur\0' 'lenovo,thinkpad-x13s\0qcom,sc8280xp\0' 'microsoft,arcata\0qcom,sc8280xp\0'; do
  dir="$scratch/other-${other%%\\0*}"
  compatible "$dir" "$other"
  run_setup "$dir" >/dev/null
  [[ ! -e $dir/mkinitcpio.conf.d ]] ||
    fail "${other%%\\0*} is left alone"
done

(
  set -eE
  dir="$scratch/not-qualcomm"
  compatible "$dir" 'lenovo,yoga-slim7x\0qcom,x1e80100\0'
  PATH="$ROOT/bin:$PATH"
  omarchy-hw-aarch64-qualcomm() { return 1; }
  OMARCHY_PROC_ROOT="$dir/proc" OMARCHY_QUALCOMM_MKINITCPIO_DIR="$dir/mkinitcpio.conf.d" source "$setup"
  [[ ! -e $dir/mkinitcpio.conf.d ]] || fail "a machine that is not a Snapdragon is left alone"
)

pass "Snapdragon X setup puts the display chain in every Hamoa and Purwa boot image"
