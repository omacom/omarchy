#!/bin/bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
PKGS_ROOT=${OMARCHY_PKGS_ROOT:-"$ROOT/../omarchy-pkgs"}
PAYLOAD=/usr/lib/omarchy/plymouth/ttfx-plymouth.so

fail() { printf 'not ok - %s\n' "$1" >&2; exit 1; }
pass() { printf 'ok - %s\n' "$1"; }

apply_system="$ROOT/bin/omarchy-apply-system"
owner="$ROOT/bin/omarchy-provision-owner"
pkgbuild="$PKGS_ROOT/pkgbuilds/omarchy/PKGBUILD"

apply_text=$(<"$apply_system")
[[ $apply_text == *'OMARCHY_FIRST_INSTALL'* &&
  $apply_text == *"ttfx_payload=$PAYLOAD"* &&
  $apply_text == *'omarchy-plymouth-ttfx-install --module "$ttfx_payload"'* ]] ||
  fail "fresh target finalization activates the native payload"
pass "fresh target finalization activates native Plymouth"

owner_text=$(<"$owner")
[[ $owner_text == *"ttfx_payload=$PAYLOAD"* &&
  $owner_text == *'omarchy-plymouth-ttfx-install --module "$ttfx_payload"'* ]] ||
  fail "deferred owner provisioning retries native activation"
[[ $owner_text == *'cmp -s'* ]] ||
  fail "deferred retry must compare the live module with the packaged payload"
pass "deferred provisioning has an idempotent activation retry"

# The runtime package lives in omarchy-pkgs; check it only when a checkout sits beside this one.
if [[ -f $pkgbuild ]]; then
  pkg_text=$(<"$pkgbuild")
  for dependency in binutils file pkgconf mkinitcpio; do
    [[ $pkg_text == *"'$dependency'"* ]] || fail "runtime package lacks native installer dependency: $dependency"
  done
  pass "runtime package declares native installer inspection tools"
else
  printf 'ok - skip runtime package dependency check (no omarchy-pkgs checkout at %s)\n' "$PKGS_ROOT"
fi
