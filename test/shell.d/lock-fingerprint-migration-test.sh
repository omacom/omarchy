#!/bin/bash
#
# Quattro's lock screen authenticates fingerprint through its own PAM service,
# /etc/pam.d/omarchy-lock-fingerprint, which is only ever written by
# omarchy-setup-security-fingerprint. A fingerprint set up before the quattro
# upgrade left pam_fprintd wired into /etc/pam.d/sudo but never went through
# that lock-specific write, since hyprlock read fingerprint auth a different
# way. This migration recreates the lock PAM file for exactly that population.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1789095456.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
sudo_pam="$test_tmp/pam-sudo"
lock_pam="$test_tmp/pam-lock-fingerprint"
migration_copy="$test_tmp/migration.sh"
mkdir -p "$stub_bin"

# The migration names both PAM paths as fixed literals, not caller-controlled,
# so the test can retarget a copy the same way the FIDO2 migration test does.
for path in /etc/pam.d/sudo /etc/pam.d/omarchy-lock-fingerprint; do
  occurrences=$(grep -Fo "$path" "$migration" | wc -l) || occurrences=0
  (( occurrences >= 1 )) ||
    fail "the migration references $path" "found $occurrences occurrences"
done
pass "migration names both PAM paths as fixed literals the test can retarget"

# Log every escalation; only a bare `tee <path>` is expected here.
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

set -euo pipefail

reject() {
  printf 'refusing unexpected sudo invocation:' >&2
  printf ' %q' "$@" >&2
  printf '\n' >&2
  exit 97
}

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"

case "$1" in
  tee)
    (( $# == 2 )) || reject "$@"
    exec /usr/bin/tee -- "$2" >/dev/null
    ;;
  *)
    reject "$@"
    ;;
esac
SH
chmod +x "$stub_bin/sudo"

run_migration() {
  : >"$calls"
  sed \
    -e "s|/etc/pam.d/sudo|$sudo_pam|g" \
    -e "s|/etc/pam.d/omarchy-lock-fingerprint|$lock_pam|g" \
    "$migration" >"$migration_copy"

  PATH="$stub_bin:$PATH" TEST_LOG="$calls" bash -euo pipefail "$migration_copy" >/dev/null
}

# Almost every machine never had a pre-quattro fingerprint setup at all.
rm -f "$sudo_pam" "$lock_pam"
run_migration
[[ ! -s $calls ]] || fail "a machine with no /etc/pam.d/sudo escalates nothing" "$(cat "$calls")"
pass "migration skips a machine with no sudo PAM stack"

# A sudo PAM stack that never had fingerprint wired in is just as untouched.
cat >"$sudo_pam" <<'EOF'
#%PAM-1.0
auth		include		system-auth
account		include		system-auth
session		include		system-auth
EOF
rm -f "$lock_pam"
run_migration
[[ ! -s $calls ]] || fail "sudo without pam_fprintd escalates nothing" "$(cat "$calls")"
pass "migration skips a machine that never set fingerprint up"

# The population this migration exists for: fingerprint already wired into
# sudo (carried over from before the quattro upgrade), but the lock screen's
# dedicated PAM service was never created.
cat >"$sudo_pam" <<'EOF'
auth      [success=1 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed
auth      sufficient pam_fprintd.so
#%PAM-1.0
auth		include		system-auth
account		include		system-auth
session		include		system-auth
EOF
rm -f "$lock_pam"
run_migration
grep -Fq $'sudo\ttee\t'"$lock_pam" "$calls" ||
  fail "a pre-existing sudo fingerprint setup gets a lock PAM file" "$(cat "$calls")"
pass "migration writes the lock PAM file for a pre-quattro fingerprint setup"

grep -Fxq 'auth       required                    pam_fprintd.so' "$lock_pam" ||
  fail "the written lock PAM file requires pam_fprintd" "$(cat "$lock_pam")"
grep -Fxq 'account    include                     system-local-login' "$lock_pam" ||
  fail "the written lock PAM file includes system-local-login" "$(cat "$lock_pam")"
pass "migration writes the same lock PAM stack the setup wizard writes"

# A second run — or a second account on the same machine — must not re-escalate
# once the lock PAM file exists, whether the wizard wrote it or this migration did.
run_migration
[[ ! -s $calls ]] || fail "an already-repaired machine escalates nothing" "$(cat "$calls")"
pass "migration is idempotent once the lock PAM file exists"
