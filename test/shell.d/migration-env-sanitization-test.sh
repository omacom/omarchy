#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
source "$ROOT/bin/omarchy-security-functions"

# omarchy-update runs omarchy-migrate through omarchy_security_run_migrations_sanitized.
# Migrations read OMARCHY_* overrides to choose the paths their privileged (sudo)
# file operations act on, and those overrides are test-only seams. Passed through
# during an update they are a local privilege-escalation seam: a user could export
# an OMARCHY_* path override, delete the migration's user-writable state marker,
# and have the next `omarchy update` retarget a root-run migration's
# write/deletion/truncation. Assert the sanitizer strips OMARCHY_* path seams while
# preserving the few vars the runtime legitimately provides.

out=$(
  OMARCHY_FPRINTD_RESUME_DST=/attacker/controlled \
    OMARCHY_ZRAM_CONF=/attacker/zram \
    OMARCHY_UPGRADE_TO_QUATTRO_LIVE=1 \
    OMARCHY_PATH=/sentinel/path \
    omarchy_security_run_migrations_sanitized bash -c '
      printf "seam_fprintd=%s\n" "${OMARCHY_FPRINTD_RESUME_DST:-<unset>}"
      printf "seam_zram=%s\n" "${OMARCHY_ZRAM_CONF:-<unset>}"
      printf "allow_quattro=%s\n" "${OMARCHY_UPGRADE_TO_QUATTRO_LIVE:-<unset>}"
      printf "allow_path=%s\n" "${OMARCHY_PATH:-<unset>}"
    '
)

grep -qx 'seam_fprintd=<unset>' <<<"$out" ||
  fail "OMARCHY_FPRINTD_RESUME_DST seam reached the migration: $(grep '^seam_fprintd=' <<<"$out")"
grep -qx 'seam_zram=<unset>' <<<"$out" ||
  fail "OMARCHY_ZRAM_CONF seam reached the migration: $(grep '^seam_zram=' <<<"$out")"
grep -qx 'allow_quattro=1' <<<"$out" ||
  fail "OMARCHY_UPGRADE_TO_QUATTRO_LIVE was stripped (the quattro upgrade needs it)"
grep -qx 'allow_path=/sentinel/path' <<<"$out" ||
  fail "OMARCHY_PATH was not preserved for the migration"

pass "the update migration sanitizer strips OMARCHY_* path seams and keeps allowlisted vars"
