#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/microsoft/surface-laptop8.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

bash -n "$setup" || fail "Surface Laptop 8 hardware script has valid syntax"

require_platform_fixtures "the Surface Laptop 8 setup"

run_setup() (
  set -eE
  local dir=$1
  PATH="$ROOT/bin:$PATH"
  omarchy-hw-aarch64-qualcomm() { return 0; }
  omarchy-pkg-add() { printf 'add %s\n' "$*" >>"$dir/packages.log"; }
  surface-laptop8-usb4-firmware() { printf 'usb4 %s\n' "$*" >>"$dir/packages.log"; return 2; }

  OMARCHY_PROC_ROOT="$dir/proc" \
    OMARCHY_SURFACE_LAPTOP8_MKINITCPIO_DIR="$dir/mkinitcpio.conf.d" \
    source "$setup"
)

compatible() {
  mkdir -p "$1/proc/device-tree"
  printf '%b' "$2" >"$1/proc/device-tree/compatible"
}

matching="$scratch/matching"
compatible "$matching" 'microsoft,surface-laptop-8-13p8\0qcom,mahua\0'
run_setup "$matching" >/dev/null
[[ $(<"$matching/packages.log") == $'add surface-laptop-8-support\nusb4 --no-rebuild' ]] ||
  fail "Surface Laptop 8 setup adds its hardware support, then copies the USB4 router firmware without stopping on failure"

(
  firmware_root="$scratch/firmware"
  board=qcom/glymur/microsoft/surface-laptop8
  mkdir -p "$firmware_root/$board" "$firmware_root/updates/$board"
  touch "$firmware_root/qcom/gen80100_sqe.fw.zst" "$firmware_root/qcom/gen80100_gmu.bin.xz" \
    "$firmware_root/$board/qcadsp8480.mbn" "$firmware_root/updates/$board/qcadsp8480.mbn" \
    "$firmware_root/updates/$board/adsp_dtbs.elf" "$firmware_root/$board/cdsp_dtbs.elf"
  MODULES=() FILES=()
  OMARCHY_SURFACE_LAPTOP8_FIRMWARE_ROOT="$firmware_root" \
    source "$matching/mkinitcpio.conf.d/surface-laptop8-initramfs.conf"

  for module in "${MODULES[@]}"; do
    [[ $module == *\? ]] || fail "$module is optional, so a kernel without it still builds its image"
  done

  expected=(
    "$firmware_root/qcom/gen80100_sqe.fw.zst"
    "$firmware_root/qcom/gen80100_gmu.bin.xz"
    "$firmware_root/updates/$board/qcadsp8480.mbn"
    "$firmware_root/updates/$board/adsp_dtbs.elf"
    "$firmware_root/$board/cdsp_dtbs.elf"
  )
  [[ ${FILES[*]} == "${expected[*]}" ]] ||
    fail "early firmware prefers extracted copies, accepts compressed packaged firmware and skips what is missing"
)

other="$scratch/other"
compatible "$other" 'lenovo,yoga-slim7x\0qcom,x1e80100\0'
run_setup "$other" >/dev/null
[[ ! -e $other/packages.log && ! -e $other/mkinitcpio.conf.d ]] ||
  fail "other Snapdragon laptops are left alone"

pass "Surface Laptop 8 setup configures only this laptop"
