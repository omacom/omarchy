#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/fix-bcm43xx.sh"
migration="$ROOT/migrations/1792750214.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

bash -n "$setup" || fail "Broadcom hardware script has valid syntax"
bash -n "$migration" || fail "BCM43228 migration has valid syntax"

actions() {
  [[ -f $scratch/actions ]] && cat "$scratch/actions" || true
}

run_setup() {
  local pci=$1
  rm -f "$scratch/actions"
  lspci() { printf '%s\n' "$pci"; }
  omarchy-pkg-add() { printf '%s\n' "$*" >>"$scratch/actions"; }
  source "$setup"
}

for chip in "BCM43228 [14e4:4359]" "BCM4360 [14e4:43a0]" "BCM4331 [14e4:4331]"; do
  run_setup "00:00.0 Network controller [0280]: Broadcom Inc. $chip" >/dev/null
  [[ $(actions) == "broadcom-wl-dkms" ]] ||
    fail "$chip installs broadcom-wl-dkms" "$(actions)"
done

run_setup "00:1f.6 Ethernet controller [0200]: Intel I219-LM [8086:15b7]" >/dev/null
[[ -z $(actions) ]] ||
  fail "other network hardware installs no Broadcom driver" "$(actions)"

run_migration() {
  local arch=$1
  local pci=$2
  local installed=$3
  rm -f "$scratch/actions"
  omarchy-hw-x86() { [[ $arch == x86 ]]; }
  lspci() { printf '%s\n' "$pci"; }
  omarchy-pkg-missing() { [[ " $installed " != *" $1 "* ]]; }
  omarchy-pkg-add() { printf 'add %s\n' "$*" >>"$scratch/actions"; }
  omarchy-state() { printf 'state %s\n' "$*" >>"$scratch/actions"; }
  source "$migration"
}

bcm43228="00:00.0 Network controller [0280]: Broadcom Inc. BCM43228 [14e4:4359]"

run_migration x86 "00:1f.6 Ethernet controller [0200]: Intel I219-LM [8086:15b7]" "" >/dev/null
[[ -z $(actions) ]] ||
  fail "the migration does nothing without a BCM43228" "$(actions)"

run_migration x86 "$bcm43228" "broadcom-wl-dkms" >/dev/null
[[ -z $(actions) ]] ||
  fail "the migration leaves an installed broadcom-wl-dkms alone" "$(actions)"

run_migration x86 "$bcm43228" "b43-firmware" >/dev/null
[[ -z $(actions) ]] ||
  fail "the migration leaves a machine running b43 on b43-firmware alone" "$(actions)"

run_migration aarch64 "$bcm43228" "" >/dev/null
[[ -z $(actions) ]] ||
  fail "the migration asks for no x86-only driver on ARM" "$(actions)"

run_migration x86 "$bcm43228" "" >/dev/null
[[ $(actions) == $'add broadcom-wl-dkms\nstate set reboot-required' ]] ||
  fail "the migration installs broadcom-wl-dkms and asks for a reboot" "$(actions)"

pass "BCM43228 gets the wl driver on install and on existing machines"
