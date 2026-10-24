#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/fix-bcm43xx.sh"
migration="$ROOT/migrations/1792747200.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

bash -n "$setup" || fail "BCM43228 hardware script has valid syntax"
bash -n "$migration" || fail "BCM43228 firmware migration has valid syntax"

run_setup() {
  local pci=$1
  rm -f "$scratch/packages"
  lspci() { printf '%s\n' "$pci"; }
  omarchy-pkg-add() { printf '%s\n' "$*" >>"$scratch/packages"; }
  source "$setup"
}

packages() {
  [[ -f $scratch/packages ]] && cat "$scratch/packages" || true
}

run_setup "00:00.0 Network controller [0280]: Broadcom Inc. BCM43228 [14e4:4359]" >/dev/null
[[ $(packages) == "b43-firmware" ]] ||
  fail "BCM43228 installs b43 firmware and not the wl driver" "$(packages)"

run_setup "00:00.0 Network controller [0280]: Broadcom Inc. BCM4360 [14e4:43a0]" >/dev/null
[[ $(packages) == "broadcom-wl-dkms" ]] ||
  fail "BCM4360 still installs broadcom-wl-dkms" "$(packages)"

run_setup "00:00.0 Network controller [0280]: Broadcom Inc. BCM4331 [14e4:4331]" >/dev/null
[[ $(packages) == "broadcom-wl-dkms" ]] ||
  fail "BCM4331 still installs broadcom-wl-dkms" "$(packages)"

run_setup "00:1f.6 Ethernet controller [0200]: Intel I219-LM [8086:15b7]" >/dev/null
[[ -z $(packages) ]] ||
  fail "other network hardware does not install a Broadcom package" "$(packages)"

stub="$scratch/bin"
mkdir -p "$stub"
cat >"$stub/lspci" <<'SH'
#!/bin/bash
printf '%s\n' "$BCM_PCI"
SH
cat >"$stub/omarchy-pkg-missing" <<'SH'
#!/bin/bash
[[ $1 == "b43-firmware" && $BCM_PACKAGE_STATE == "missing" ]]
SH
cat >"$stub/pacman" <<'SH'
#!/bin/bash
[[ $1 == "-Si" && $2 == "--" && $3 == "b43-firmware" && $BCM_PACKAGE_PUBLISHED == "yes" ]]
SH
cat >"$stub/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'add %s\n' "$*" >>"$BCM_ACTIONS"
SH
cat >"$stub/omarchy-state" <<'SH'
#!/bin/bash
printf 'state %s\n' "$*" >>"$BCM_ACTIONS"
SH
chmod +x "$stub"/*

run_migration() {
  local pci=$1
  local present=$2
  local published=$3
  : >"$scratch/actions"
  BCM_PCI=$pci \
    BCM_PACKAGE_STATE=$present \
    BCM_PACKAGE_PUBLISHED=$published \
    BCM_ACTIONS=$scratch/actions \
    PATH="$stub:$PATH" \
    bash -euo pipefail "$migration"
}

actions() {
  [[ -f $scratch/actions ]] && cat "$scratch/actions" || true
}

run_migration "00:00.0 Ethernet controller [0200]: Intel [8086:15b7]" missing yes >/dev/null
[[ -z $(actions) ]] ||
  fail "the migration does nothing without a BCM43228" "$(actions)"

run_migration "00:00.0 Network controller [0280]: Broadcom Inc. BCM43228 [14e4:4359]" present yes >/dev/null
[[ -z $(actions) ]] ||
  fail "the migration leaves an installed b43-firmware package alone" "$(actions)"

run_migration "00:00.0 Network controller [0280]: Broadcom Inc. BCM43228 [14e4:4359]" missing yes >/dev/null
[[ $(actions) == $'add b43-firmware\nstate set reboot-required' ]] ||
  fail "the migration installs b43 firmware and asks for a reboot" "$(actions)"

if (run_migration "00:00.0 Network controller [0280]: Broadcom Inc. BCM43228 [14e4:4359]" missing no >/dev/null 2>&1); then
  fail "the migration stays pending when b43-firmware is not published"
fi
[[ -z $(actions) ]] ||
  fail "an unpublished b43-firmware package is not treated as installed" "$(actions)"

pass "BCM43228 gets b43 firmware and the other Broadcom chips still get wl"
