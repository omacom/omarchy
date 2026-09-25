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

run_surface_setup() (
  machine=$1
  script=$2
  omarchy-hw-surface() { return 0; }
  uname() { [[ $1 == "-m" ]] && printf '%s\n' "$machine"; }
  omarchy-pkg-add() { printf '%s\n' "$*" >>"$scratch/packages"; }
  lsmod() { printf 'lsmod\n' >>"$scratch/probes"; }
  source "$script"
)

rm -f "$scratch/packages" "$scratch/probes"
run_surface_setup aarch64 "$surface_setup" >/dev/null
[[ ! -e $scratch/packages ]] ||
  fail "Surface setup skips Marvell firmware on Snapdragon Surfaces"

run_surface_setup aarch64 "$keyboard_setup" >/dev/null
[[ ! -e $scratch/probes ]] ||
  fail "Surface keyboard setup skips Intel modules on Snapdragon Surfaces"

run_surface_setup x86_64 "$surface_setup" >/dev/null
[[ $(<"$scratch/packages") == "linux-firmware-marvell" ]] ||
  fail "Surface setup installs Marvell firmware on Intel Surfaces"

pass "Surface hardware setup applies Intel fixes only on x86_64"
