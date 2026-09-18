#!/bin/bash

set -euo pipefail

# The fingerprint clamshell gate must exit 0 on the common lid-open path so
# pam_exec does not fill the journal with LOG_ERR on every sudo/polkit auth.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/bin/omarchy-hw-laptop-open"
[[ -x $helper ]] || fail "omarchy-hw-laptop-open is executable"

# Match the closed helper's ACPI path convention.
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

pass "fingerprint setup installs the silent lid-open PAM gate"

remove="$ROOT/bin/omarchy-remove-security-fingerprint"
grep -q 'omarchy-hw-laptop-open' "$remove" ||
  fail "fingerprint remove strips the lid-open PAM gate"

pass "fingerprint remove strips both gate polarities"

migration="$ROOT/migrations/1789400300.sh"
[[ -f $migration ]] || fail "a migration rewrites existing PAM gates to the silent polarity"
grep -q 'omarchy-hw-laptop-open' "$migration" ||
  fail "migration installs the lid-open PAM gate"
grep -q 'omarchy-hw-laptop-closed' "$migration" ||
  fail "migration removes the lid-closed PAM gate"
grep -q '/etc/pam.d/sudo' "$migration" ||
  fail "migration rewrites sudo"
grep -q '/etc/pam.d/polkit-1' "$migration" ||
  fail "migration rewrites polkit"
! grep -q 'omarchy-lock-fingerprint' "$migration" ||
  fail "migration must not gate the lock PAM stack (skipping pam_fprintd unlocks)"

pass "migration flips sudo/polkit fingerprint PAM gates to the silent polarity"
