#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

# Exercises migrations/1788256455.sh, which repairs an Omarchy-created
# /etc/pam.d/polkit-1 that lists pam_unix directly (dropping pam_faillock)
# instead of including system-auth. The migration keeps its production path
# fixed; as in sshd-hardening-migration-test.sh, this test rewrites that one
# assignment in the input fed to bash and stubs sudo so nothing touches the
# host's /etc.

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

migration="$ROOT/migrations/1788256455.sh"
stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

# sudo stub: log, optionally refuse (SUDO_ALLOWED=0), and optionally make the
# `sed` rewrite empty the file and report success (WRITE_BREAKS=1) so the
# verification/restore path is exercised. Otherwise run the real command so
# cp/sed act on the temp file.
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"${CALL_LOG:?}"
if [[ ${SUDO_ALLOWED:-1} != "1" ]]; then
  exit 1
elif [[ ${WRITE_BREAKS:-0} == "1" && $1 == "sed" ]]; then
  : >"${!#}"
else
  exec "$@"
fi
STUB
chmod +x "$stub_bin"/*

# Run the migration against a polkit-1 file seeded with $1; leaves the result in
# "$test_dir/<scenario>/polkit-1" and records the exit status in migrate_rc.
migrate_rc=0
run_migration() {
  local scenario=$1 content=$2
  local dir="$test_dir/$scenario"
  local polkit="$dir/polkit-1"
  mkdir -p "$dir"
  printf '%s' "$content" >"$polkit"
  : >"$test_dir/$scenario.calls"

  migrate_rc=0
  sed "s|^polkit=/etc/pam.d/polkit-1\$|polkit=$polkit|" "$migration" |
    CALL_LOG="$test_dir/$scenario.calls" PATH="$stub_bin:$PATH" \
      SUDO_ALLOWED="${SUDO_ALLOWED:-1}" WRITE_BREAKS="${WRITE_BREAKS:-0}" \
      bash -euo pipefail >/dev/null 2>&1 || migrate_rc=$?
}

result() { cat "$test_dir/$1/polkit-1"; }

# The four layouts the old setup / remove commands leave behind.
fingerprint_stack='auth      [success=1 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed
auth      sufficient pam_fprintd.so
auth      required pam_unix.so

account   required pam_unix.so
password  required pam_unix.so
session   required pam_unix.so
'
fido2_stack='auth      sufficient pam_u2f.so cue authfile=/etc/fido2/fido2
auth      required pam_unix.so

account   required pam_unix.so
password  required pam_unix.so
session   required pam_unix.so
'
both_stack='auth      [success=1 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed
auth      sufficient pam_fprintd.so
auth      sufficient pam_u2f.so cue authfile=/etc/fido2/fido2
auth      required pam_unix.so

account   required pam_unix.so
password  required pam_unix.so
session   required pam_unix.so
'
# What both remove commands leave: their own marker lines stripped, the bare
# pam_unix stack (and no marker) behind.
markerless_stack='auth      required pam_unix.so

account   required pam_unix.so
password  required pam_unix.so
session   required pam_unix.so
'
fixed_stack='auth      sufficient pam_fprintd.so
auth      include system-auth
account   include system-auth
password  include system-auth
session   include system-auth
'
# An administrator's own stack that happens to use pam_fprintd but carries an
# extra directive Omarchy never writes.
admin_stack='auth      sufficient pam_fprintd.so
auth      required pam_unix.so
auth      optional pam_permit.so
account   required pam_unix.so
password  required pam_unix.so
session   required pam_unix.so
'

# Every phase of a repaired stack must defer to system-auth and no bare pam_unix
# may remain in the account/password/session block.
assert_repaired() {
  local scenario=$1 phase
  for phase in auth account password session; do
    grep -qE "^${phase}[[:space:]]+include[[:space:]]+system-auth" <<<"$(result "$scenario")" ||
      fail "$scenario: $phase defers to system-auth" "$(result "$scenario")"
  done
  ! grep -qE '^(account|password|session)[[:space:]]+required[[:space:]]+pam_unix' <<<"$(result "$scenario")" ||
    fail "$scenario: no bare pam_unix remains" "$(result "$scenario")"
}

run_migration fingerprint "$fingerprint_stack"
(( migrate_rc == 0 )) || fail "fingerprint stack migrates cleanly"
assert_repaired fingerprint
grep -qF 'pam_fprintd.so' <<<"$(result fingerprint)" || fail "fingerprint line is preserved"
grep -qF 'omarchy-hw-laptop-closed' <<<"$(result fingerprint)" || fail "clamshell gate is preserved"
pass "migration repairs the fingerprint stack and keeps its hardware-auth lines"

run_migration fido2 "$fido2_stack"
(( migrate_rc == 0 )) || fail "fido2 stack migrates cleanly"
assert_repaired fido2
grep -qF 'pam_u2f.so cue authfile=/etc/fido2/fido2' <<<"$(result fido2)" || fail "FIDO2 line is preserved"
pass "migration repairs the FIDO2 stack and keeps its hardware-auth line"

run_migration both "$both_stack"
(( migrate_rc == 0 )) || fail "combined stack migrates cleanly"
assert_repaired both
grep -qF 'pam_fprintd.so' <<<"$(result both)" && grep -qF 'pam_u2f.so' <<<"$(result both)" ||
  fail "both hardware-auth lines are preserved"
pass "migration repairs a combined fingerprint+FIDO2 stack"

run_migration markerless "$markerless_stack"
(( migrate_rc == 0 )) || fail "markerless stack migrates cleanly"
assert_repaired markerless
pass "migration repairs the markerless post-removal stack"

run_migration comment "# managed by omarchy
$fingerprint_stack"
(( migrate_rc == 0 )) || fail "commented stack migrates cleanly"
assert_repaired comment
grep -qxF '# managed by omarchy' <<<"$(result comment)" || fail "comments are preserved through the rewrite"
pass "migration repairs a commented stack and preserves the comment"

run_migration commented-include "# auth include system-auth
$fingerprint_stack"
(( migrate_rc == 0 )) || fail "a stack with a commented-out include migrates cleanly"
assert_repaired commented-include
pass "migration repairs a stack whose only include is commented out"

run_migration fixed "$fixed_stack"
[[ "$(result fixed)" == "$(printf '%s' "$fixed_stack")" ]] || fail "an already-fixed stack is left byte-for-byte unchanged"
! grep -q '^sudo ' "$test_dir/fixed.calls" || fail "an already-fixed stack triggers no privileged writes"
pass "migration is idempotent: an already-fixed stack is untouched"

run_migration admin "$admin_stack"
[[ "$(result admin)" == "$(printf '%s' "$admin_stack")" ]] || fail "an administrator-authored stack is left unchanged"
! grep -q '^sudo ' "$test_dir/admin.calls" || fail "an administrator-authored stack triggers no privileged writes"
pass "migration refuses a stack carrying non-Omarchy directives"

# Privilege failure is the retryable case: the migration must exit non-zero so
# omarchy-migrate does not record it complete, and must leave the file unchanged.
SUDO_ALLOWED=0 run_migration no-sudo "$fingerprint_stack"
(( migrate_rc != 0 )) || fail "the migration stays pending when privileges are unavailable"
[[ "$(result no-sudo)" == "$(printf '%s' "$fingerprint_stack")" ]] || fail "a failed repair leaves the original file intact"
pass "migration exits non-zero and preserves the file when sudo is refused"

# A write that does not take effect must be caught by verification, restored,
# and reported as a failure rather than silently marked complete.
WRITE_BREAKS=1 run_migration verify-fail "$fingerprint_stack"
(( migrate_rc != 0 )) || fail "a failed verification exits non-zero"
[[ "$(result verify-fail)" == "$(printf '%s' "$fingerprint_stack")" ]] || fail "a failed verification restores the original file"
pass "migration exits non-zero and restores when the write cannot be verified"

# A stack already rewritten to the lid-open gate still has the bare pam_unix
# lines the shipped repair knows how to fix, but that repair only accepts the
# old lid-closed gate. The later migration has to repair this shape, keep the
# open gate verbatim, and still refuse an edited file.
open_gate='auth      [success=ignore default=1] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-open'
open_vulnerable="${open_gate}
auth      sufficient pam_fprintd.so
auth      required pam_unix.so

account   required pam_unix.so
password  required pam_unix.so
session   required pam_unix.so
"
open_admin="${open_gate}
auth      sufficient pam_fprintd.so
auth      required pam_unix.so
auth      optional pam_permit.so

account   required pam_unix.so
password  required pam_unix.so
session   required pam_unix.so
"
later_migration="$ROOT/migrations/1791150200.sh"

run_later() {
  local scenario=$1 content=$2
  local dir="$test_dir/$scenario"
  local polkit="$dir/polkit-1"
  mkdir -p "$dir"
  printf '%s' "$content" >"$polkit"
  : >"$test_dir/$scenario.calls"

  migrate_rc=0
  sed "s|^polkit=/etc/pam.d/polkit-1\$|polkit=$polkit|" "$later_migration" |
    CALL_LOG="$test_dir/$scenario.calls" PATH="$stub_bin:$PATH" \
      SUDO_ALLOWED="${SUDO_ALLOWED:-1}" WRITE_BREAKS="${WRITE_BREAKS:-0}" \
      bash -euo pipefail >/dev/null 2>&1 || migrate_rc=$?
}

run_migration open-shipped "$open_vulnerable"
(( migrate_rc == 0 )) || fail "the shipped repair exits cleanly on a lid-open stack"
[[ "$(result open-shipped)" == "$(printf '%s' "$open_vulnerable")" ]] ||
  fail "the shipped repair leaves a lid-open vulnerable stack unchanged" "$(result open-shipped)"
pass "shipped repair does not recognize a lid-open vulnerable stack"

run_later open-repaired "$open_vulnerable"
(( migrate_rc == 0 )) || fail "the later migration repairs a lid-open vulnerable stack"
assert_repaired open-repaired
grep -qF "$open_gate" <<<"$(result open-repaired)" ||
  fail "the later migration keeps the lid-open gate verbatim" "$(result open-repaired)"
! grep -q 'omarchy-hw-laptop-closed' <<<"$(result open-repaired)" ||
  fail "the later migration does not add the lid-closed gate"
pass "later migration repairs a lid-open vulnerable stack and keeps that gate"

run_migration open-admin-shipped "$open_admin"
[[ "$(result open-admin-shipped)" == "$(printf '%s' "$open_admin")" ]] ||
  fail "the shipped repair leaves an edited lid-open stack unchanged"
run_later open-admin "$open_admin"
[[ "$(result open-admin)" == "$(printf '%s' "$open_admin")" ]] ||
  fail "the later migration leaves an edited lid-open stack unchanged" "$(result open-admin)"
! grep -q '^sudo ' "$test_dir/open-admin.calls" ||
  fail "an edited lid-open stack triggers no privileged writes"
pass "later migration refuses a lid-open stack that carries another directive"

run_migration closed-then-flip "$fingerprint_stack"
assert_repaired closed-then-flip
grep -qF 'omarchy-hw-laptop-closed' <<<"$(result closed-then-flip)" ||
  fail "the shipped repair keeps the lid-closed gate"
gate_dir="$test_dir/gate-flip"
mkdir -p "$gate_dir"
cp "$test_dir/closed-then-flip/polkit-1" "$gate_dir/polkit-1"
sed -e "s|/etc/pam.d/sudo|$gate_dir/sudo|" -e "s|/etc/pam.d/polkit-1|$gate_dir/polkit-1|" \
  "$ROOT/migrations/1789385397.sh" |
  CALL_LOG="$test_dir/gate-flip.calls" PATH="$stub_bin:$PATH" bash -euo pipefail >/dev/null
grep -qF "$open_gate" "$gate_dir/polkit-1" ||
  fail "the silent-gate migration installs the lid-open gate" "$(cat "$gate_dir/polkit-1")"
! grep -q 'omarchy-hw-laptop-closed' "$gate_dir/polkit-1" ||
  fail "the silent-gate migration removes the lid-closed gate"
grep -qE '^auth[[:space:]]+include[[:space:]]+system-auth' "$gate_dir/polkit-1" ||
  fail "the silent-gate migration keeps the system-auth include"
pass "silent-gate migration flips a repaired stack to the lid-open gate"

run_later closed-by-later "$fingerprint_stack"
(( migrate_rc == 0 )) || fail "the later migration repairs a lid-closed vulnerable stack"
assert_repaired closed-by-later
grep -qF "$open_gate" <<<"$(result closed-by-later)" ||
  fail "the later migration swaps a lid-closed gate to lid-open" "$(result closed-by-later)"
! grep -q 'omarchy-hw-laptop-closed' <<<"$(result closed-by-later)" ||
  fail "the later migration removes the lid-closed gate from a vulnerable stack"
pass "later migration repairs a lid-closed vulnerable stack onto the lid-open gate"
