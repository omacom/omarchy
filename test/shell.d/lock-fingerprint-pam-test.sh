#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/bin/omarchy-setup-security-fingerprint"
apply_lock="$ROOT/bin/omarchy-apply-lock"
migration="$ROOT/migrations/1788600001.sh"

lock_writer=$(awk '/^setup_lock_fingerprint_pam/,/^}/' "$setup")
if grep -qE 'omarchy-hw-laptop-closed|lock_fprintd_gate' <<<"$lock_writer"; then
  fail "lock-screen fingerprint PAM has no lid gate"
fi
if grep -q 'success=die' "$setup" || grep -q 'success=die' "$apply_lock"; then
  fail "lock fingerprint writers do not die on a closed lid"
fi
grep -q 'success=1' "$setup" || fail "sudo and polkit still skip fingerprint when the lid is closed"
if grep -q 'every stack' "$setup"; then
  fail "the clamshell-gate comment does not claim the lock stack"
fi
pass "lock fingerprint PAM stays ungated; sudo and polkit keep the skip"

[[ -f $migration ]] || fail "a migration strips leftover lid gates from the lock stack"
if grep -q 'success=die' "$migration"; then
  fail "the lock migration does not install a die gate"
fi
grep -q 'omarchy-hw-laptop-closed' "$migration" ||
  fail "the lock migration names the leftover pam_exec gate"
pass "lock migration is a strip, not a die-gate install"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
pam="$test_dir/omarchy-lock-fingerprint"

run_migration() {
  local script="$test_dir/migration.sh"
  sed "s|/etc/pam.d/omarchy-lock-fingerprint|$pam|g" "$migration" >"$script"
  bash -euo pipefail "$script" >/dev/null
}

cat >"$pam" <<'EOF'
#%PAM-1.0
auth       [success=1 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed
auth       required                    pam_fprintd.so
account    include                     system-local-login
EOF
run_migration
if grep -q 'omarchy-hw-laptop-closed' "$pam"; then
  fail "migration removes a success=1 lock gate that would unlock"
fi
grep -q 'pam_fprintd.so' "$pam" || fail "migration keeps pam_fprintd"
pass "migration removes a success=1 lock gate"

cat >"$pam" <<'EOF'
#%PAM-1.0
auth      [success=die default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed
auth       required                    pam_fprintd.so
account    include                     system-local-login
EOF
run_migration
if grep -q 'omarchy-hw-laptop-closed' "$pam"; then
  fail "migration removes a die gate from the lock stack"
fi
pass "migration removes a die gate from the lock stack"

cat >"$pam" <<'EOF'
#%PAM-1.0
auth       required                    pam_fprintd.so
account    include                     system-local-login
EOF
before=$(cat "$pam")
run_migration
run_migration
[[ $(cat "$pam") == "$before" ]] || fail "migration is idempotent on an ungated lock stack"
pass "migration is idempotent on an ungated lock stack"
