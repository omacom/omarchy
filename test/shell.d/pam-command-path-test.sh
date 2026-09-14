#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

old_path='PATH DEFAULT=/usr/local/sbin:/usr/local/bin:/usr/bin:@{HOME}/.local/share/mise/shims:@{HOME}/.local/bin'
new_path='PATH DEFAULT=@{HOME}/.local/share/mise/shims:@{HOME}/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin'
comment='# Omarchy: give SSH commands and other non-shell logins the user-level tool paths'

migration=$(grep -rl 'Put user-level tool paths ahead of /usr/bin in the PAM PATH' "$ROOT/migrations" | head -n 1 || true)
[[ -n $migration ]] || fail "PAM PATH order migration exists"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
mkdir -p "$fake_bin"
cat >"$fake_bin/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$TEST_LOG"
exec "$@"
STUB
chmod +x "$fake_bin/sudo"

run_install() {
  OMARCHY_PAM_ENV_CONF="$1" bash -euo pipefail "$ROOT/install/config/ssh-command-path.sh"
}

run_migration() {
  : >"$TEST_LOG"
  TEST_LOG="$TEST_LOG" \
    PATH="$fake_bin:$PATH" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_PAM_ENV_CONF="$1" \
    bash -euo pipefail "$migration" >/dev/null
}

TEST_LOG="$test_tmp/calls.log"

pam="$test_tmp/empty.conf"
: >"$pam"
run_install "$pam"
grep -qxF "$comment" "$pam" || fail "install writes the Omarchy PAM PATH comment"
grep -qxF "$new_path" "$pam" || fail "install writes user-level paths before /usr/bin"
! grep -qxF "$old_path" "$pam" || fail "install does not write the old PATH order"
pass "install writes the new PAM PATH on a file with no PATH line"

before=$(cat "$pam")
run_install "$pam"
[[ $(cat "$pam") == "$before" ]] || fail "install is a no-op when the new PATH is already present"
pass "install is a no-op when the new PATH is already present"

pam="$test_tmp/old.conf"
printf '%s\n%s\n' "$comment" "$old_path" >"$pam"
run_install "$pam"
grep -qxF "$new_path" "$pam" || fail "install rewrites the old Omarchy PATH line"
! grep -qxF "$old_path" "$pam" || fail "install removes the old Omarchy PATH line"
grep -qxF "$comment" "$pam" || fail "install keeps the surrounding PAM comment when rewriting"
pass "install rewrites the old Omarchy PATH line"

pam="$test_tmp/custom.conf"
printf '%s\n' 'PATH DEFAULT=/opt/custom/bin:/usr/bin' >"$pam"
run_install "$pam"
grep -qxF 'PATH DEFAULT=/opt/custom/bin:/usr/bin' "$pam" || fail "install leaves a hand-edited PATH alone"
! grep -qxF "$new_path" "$pam" || fail "install does not append when a custom PATH exists"
pass "install leaves a hand-edited PATH alone"

pam="$test_tmp/migrate-old.conf"
printf '%s\n%s\n' "$comment" "$old_path" >"$pam"
run_migration "$pam"
grep -qxF "$new_path" "$pam" || fail "migration rewrites the old Omarchy PATH line"
! grep -qxF "$old_path" "$pam" || fail "migration removes the old Omarchy PATH line"
grep -q '^sudo env OMARCHY_PAM_ENV_CONF=' "$TEST_LOG" || fail "migration uses sudo to rewrite PAM PATH"
pass "migration rewrites the old Omarchy PATH line"

pam="$test_tmp/migrate-new.conf"
printf '%s\n%s\n' "$comment" "$new_path" >"$pam"
run_migration "$pam"
[[ ! -s $TEST_LOG ]] || fail "migration does not sudo when the new PATH is already present" "$(cat "$TEST_LOG")"
pass "migration is a no-op when the new PATH is already present"

pam="$test_tmp/migrate-custom.conf"
printf '%s\n' 'PATH DEFAULT=/opt/custom/bin:/usr/bin' >"$pam"
run_migration "$pam"
grep -qxF 'PATH DEFAULT=/opt/custom/bin:/usr/bin' "$pam" || fail "migration leaves a hand-edited PATH alone"
[[ ! -s $TEST_LOG ]] || fail "migration does not sudo for a hand-edited PATH" "$(cat "$TEST_LOG")"
pass "migration leaves a hand-edited PATH alone"

pam="$test_tmp/migrate-missing.conf"
: >"$pam"
run_migration "$pam"
grep -qxF "$new_path" "$pam" || fail "migration writes the new PATH when none is set"
pass "migration writes the new PATH when none is set"
