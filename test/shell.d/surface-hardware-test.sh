#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

surface_setup="$ROOT/install/hardware/surface.sh"
keyboard_setup="$ROOT/install/hardware/fix-surface-keyboard.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

for script in "$surface_setup" "$keyboard_setup"; do
  bash -n "$script" || fail "Surface hardware scripts have valid syntax"
done

mkinitcpio_dir="$scratch/mkinitcpio.conf.d"
module_list="$mkinitcpio_dir/surface_device_modules.conf"

# A third argument is what the mocked lsmod prints; without one, no module is
# detected and the script writes nothing.
run_surface_setup() (
  machine=$1
  script=$2
  loaded_modules=${3:-}
  omarchy-hw-surface() { return 0; }
  omarchy-hw-x86() { [[ $machine == "x86_64" ]]; }
  omarchy-pkg-add() { printf '%s\n' "$*" >>"$scratch/packages"; }
  lsmod() {
    printf 'lsmod\n' >>"$scratch/probes"
    printf '%s\n' "$loaded_modules"
  }
  # The keyboard script reads the DMI product name from sysfs, which ARM
  # machines and containers may not have. Answer that read as an Intel Surface
  # so the test does not depend on the host's firmware tables.
  cat() {
    if [[ $* == "/sys/class/dmi/id/product_name" ]]; then
      printf 'Surface Laptop 3\n'
    else
      command cat "$@"
    fi
  }
  OMARCHY_SURFACE_MKINITCPIO_DIR="$mkinitcpio_dir" source "$script"
)

rm -f "$scratch/packages" "$scratch/probes"
run_surface_setup aarch64 "$surface_setup" >/dev/null
[[ ! -e $scratch/packages ]] ||
  fail "Surface setup skips Marvell firmware on Snapdragon Surfaces"

# What lsmod reports on a Surface Pro 11, where the Intel module list would break mkinitcpio.
run_surface_setup aarch64 "$keyboard_setup" "pinctrl_sm8550_lpass_lpi 12288 1" >/dev/null
[[ ! -e $scratch/probes && ! -e $module_list ]] ||
  fail "Surface keyboard setup skips Intel modules on Snapdragon Surfaces"

run_surface_setup x86_64 "$surface_setup" >/dev/null
[[ $(<"$scratch/packages") == "linux-firmware-marvell" ]] ||
  fail "Surface setup installs Marvell firmware on Intel Surfaces"

run_surface_setup x86_64 "$keyboard_setup" >/dev/null
[[ -e $scratch/probes && ! -e $module_list ]] ||
  fail "Surface keyboard setup probes modules on Intel Surfaces and writes nothing without a pinctrl module"

run_surface_setup x86_64 "$keyboard_setup" "pinctrl_tigerlake 32768 0" >/dev/null
[[ -f $module_list ]] ||
  fail "Surface keyboard setup writes the initramfs module list on Intel Surfaces"
[[ $(<"$module_list") == "MODULES=(pinctrl_tigerlake surface_aggregator surface_aggregator_registry surface_aggregator_hub surface_hid_core surface_hid surface_kbd intel_lpss_pci 8250_dw)" ]] ||
  fail "Surface keyboard setup lists the detected pinctrl module ahead of the Surface and Intel LPSS modules" "$(<"$module_list")"

pass "Surface hardware setup applies Intel fixes only on x86_64"
