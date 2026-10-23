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
  local pci=$1
  local installed=$2
  rm -f "$scratch/actions"
  lspci() { printf '%s\n' "$pci"; }
  omarchy-pkg-missing() { [[ $installed == no ]]; }
  omarchy-pkg-add() { printf 'add %s\n' "$*" >>"$scratch/actions"; }
  omarchy-state() { printf 'state %s\n' "$*" >>"$scratch/actions"; }
  source "$migration"
}

run_migration "00:1f.6 Ethernet controller [0200]: Intel I219-LM [8086:15b7]" no >/dev/null
[[ -z $(actions) ]] ||
  fail "the migration does nothing without a BCM43228" "$(actions)"

run_migration "00:00.0 Network controller [0280]: Broadcom Inc. BCM43228 [14e4:4359]" yes >/dev/null
[[ -z $(actions) ]] ||
  fail "the migration leaves an installed broadcom-wl-dkms alone" "$(actions)"

if [[ ! -d /usr/lib/firmware/b43 ]]; then
  run_migration "00:00.0 Network controller [0280]: Broadcom Inc. BCM43228 [14e4:4359]" no >/dev/null
  [[ $(actions) == $'add broadcom-wl-dkms\nstate set reboot-required' ]] ||
    fail "the migration installs broadcom-wl-dkms and asks for a reboot" "$(actions)"
fi

pass "BCM43228 gets the wl driver on install and on existing machines"
