#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/bin/omarchy-hw-laptop-open"
[[ -x $helper ]] || fail "omarchy-hw-laptop-open is executable"
grep -q '/proc/acpi/button/lid' "$helper" ||
  fail "omarchy-hw-laptop-open reads the ACPI lid state"
grep -q 'exit 1' "$helper" ||
  fail "omarchy-hw-laptop-open exits 1 when the lid is closed"
grep -q 'exit 0' "$helper" ||
  fail "omarchy-hw-laptop-open exits 0 when the lid is open"
pass "omarchy-hw-laptop-open is the silent lid-open helper"

setup="$ROOT/bin/omarchy-setup-security-fingerprint"
grep -q 'omarchy-hw-laptop-open' "$setup" ||
  fail "fingerprint setup installs the lid-open PAM gate"
grep -q '\[success=ignore default=1\]' "$setup" ||
  fail "fingerprint setup uses success=ignore default=1 for the lid-open gate"
! grep -q 'omarchy-hw-laptop-closed' <<<"$(grep fprintd_gate= "$setup")" ||
  fail "fingerprint setup gate line must not call omarchy-hw-laptop-closed"
lock_writer=$(awk '/^setup_lock_fingerprint_pam/,/^}/' "$setup")
if grep -qE 'omarchy-hw-laptop-(open|closed)|lock_fprintd_gate' <<<"$lock_writer"; then
  fail "lock-screen fingerprint PAM has no lid gate"
fi
pass "fingerprint setup installs the silent lid-open PAM gate on sudo and polkit only"

remove="$ROOT/bin/omarchy-remove-security-fingerprint"
grep -q 'omarchy-hw-laptop-open' "$remove" ||
  fail "fingerprint remove strips the lid-open PAM gate"
grep -q 'omarchy-hw-laptop-closed' "$remove" ||
  fail "fingerprint remove still strips leftover lid-closed PAM gates"
pass "fingerprint remove strips both gate polarities"

migration=""
for candidate in "$ROOT"/migrations/*.sh; do
  if grep -q 'omarchy-hw-laptop-open' "$candidate" &&
    grep -q 'omarchy-hw-laptop-closed' "$candidate"; then
    migration=$candidate
    break
  fi
done
[[ -n $migration ]] || fail "a migration rewrites existing PAM gates to the silent polarity"
if grep -q 'omarchy-lock-fingerprint' "$migration"; then
  fail "the silent-gate migration does not install a gate on the lock stack"
fi
grep -q '/etc/pam.d/sudo' "$migration" ||
  fail "silent-gate migration rewrites sudo"
grep -q 'polkit-1' "$migration" ||
  fail "silent-gate migration rewrites polkit"
pass "migration flips sudo and polkit gates without touching lock PAM"
