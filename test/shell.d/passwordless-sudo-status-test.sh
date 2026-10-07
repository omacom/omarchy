#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/passwordless-sudo-test.sh"

status_dir="$test_tmp/run/omarchy-sudo-passwordless"
marker="$status_dir/1000"

reset_grant
(
  source "$library"
  enable_locked 1000 15
  read_grant 1000
  [[ -f $marker && $(stat -c '%a' "$marker") == 644 && $(stat -c '%a' "$status_dir") == 755 ]]
  [[ $(/usr/bin/date -u -d "@$(cat "$marker")" +%Y%m%d%H%M%SZ) == "$GRANT_DEADLINE" ]]
  ! compgen -G "$status_dir/.pending.*"
  # The marker lands before the rule, so a live rule is never without one.
  marker_move=$(grep -n "^mv .*$status_dir/1000\$" "$test_tmp/commands" | tail -1 | cut -d: -f1)
  rule_move=$(grep -n "^mv .*$(rule_file 1000)\$" "$test_tmp/commands" | tail -1 | cut -d: -f1)
  (( marker_move < rule_move ))
  output=$(print_status 1 1000)
  [[ $output =~ ^\{\"active\":true,\"remaining_seconds\":([0-9]+),\"deadline\":\"[0-9T:-]+Z\"\}$ ]]
  (( BASH_REMATCH[1] > 840 && BASH_REMATCH[1] <= 900 ))
  [[ $(print_status 0 1000) == "Passwordless sudo is ACTIVE for 15 more minutes"* ]]
)
pass "a grant publishes a root-owned, world-readable deadline marker before its rule"

(
  source "$library"
  cleanup_uid_locked 1000
  [[ ! -e $(rule_file 1000) && ! -e $marker ]]
  assert_status 3 print_status 1 1000
  [[ $(print_status 1 1000 || true) == '{"active":false,"remaining_seconds":0,"deadline":null}' ]]
  [[ $(print_status 0 1000 || true) == "Passwordless sudo is inactive." ]]
)
pass "revocation removes the marker and status reports confirmed inactivity"

reset_grant
(
  source "$library"
  enable_locked 1000 15
  TEST_DELETE_FAIL=1 assert_status 1 cleanup_uid_locked 1000
  [[ -e $(rule_file 1000) && -e $marker ]]
  assert_status 0 print_status 1 1000 >/dev/null
  TEST_DELETE_FAIL=1 assert_status 1 cleanup_all_locked
  [[ -e $(rule_file 1000) && -e $marker ]]
  printf '1\n' >"$status_dir/1001"
  cleanup_all_locked
  ! compgen -G "$status_dir/*"
)
pass "a marker outlives its rule only while the rule cannot be removed"

reset_grant
(
  source "$library"
  enable_locked 1000 15
  TEST_EXPIRED=1 expire_locked 1000
  [[ ! -e $(rule_file 1000) && ! -e $marker ]]
  printf '%s\n' "$(( $(/usr/bin/date +%s) + 600 ))" >"$marker"
  expire_locked 1000
  [[ ! -e $marker ]]
)
pass "expiry removes the marker with its rule and clears a marker left without one"

reset_grant
(
  source "$library"
  install -d -m 0755 "$status_dir"
  printf '%s\n' "$(( $(/usr/bin/date +%s) - 1 ))" >"$marker"
  assert_status 3 print_status 1 1000 >/dev/null
  for contents in '' 'soon' '-5' '1234567890123'; do
    printf '%s\n' "$contents" >"$marker"
    assert_status 2 print_status 1 1000 >/dev/null
  done
  printf '%s\n' "$(( $(/usr/bin/date +%s) + 600 ))" >"$marker"
  TEST_BAD_PATH="$marker" assert_status 2 print_status 1 1000 >/dev/null
  TEST_BAD_PATH="$status_dir" assert_status 2 print_status 1 1000 >/dev/null
  rm "$marker"
  ln -s "$test_tmp/commands" "$marker"
  assert_status 2 print_status 1 1000 >/dev/null
)
pass "status treats a past deadline as inactive and an untrusted or malformed marker as an error"

reset_grant
(
  source "$library"
  enable_locked 1000 30
  read_grant 1000
  longer=$(cat "$marker")
  cp "$(rule_file 1000)" "$test_tmp/longer-rule"
  # A publisher killed between the marker and the rule must leave the marker
  # covering the old, later deadline the still-live rule carries.
  TEST_KILL_RULE_PUBLISH=1 assert_status 137 enable_locked 1000 5
  rm -f "$test_tmp/etc/sudoers.d/".omarchy-nopasswd.*
  cmp "$(rule_file 1000)" "$test_tmp/longer-rule"
  (( $(cat "$marker") >= longer ))
  assert_status 0 print_status 1 1000 >/dev/null
  : >"$test_tmp/commands"
  enable_locked 1000 5
  read_grant 1000
  [[ $(/usr/bin/date -u -d "@$(cat "$marker")" +%Y%m%d%H%M%SZ) == "$GRANT_DEADLINE" ]]
  (( $(grep -c "^mv .*$status_dir/1000\$" "$test_tmp/commands") == 2 ))
)
pass "a shortening renewal keeps the marker at the later deadline until the new rule is live"

reset_grant
(
  source "$library"
  enable_locked 1000 15
  # Root can still search a mode-0700 directory, but the user cannot: every
  # marker test would fail and look like inactivity.
  chmod 0700 "$status_dir"
  assert_status 2 print_status 1 1000 >/dev/null
  chmod 0755 "$status_dir"
  cleanup_uid_locked 1000
  rmdir "$status_dir"
  assert_status 3 print_status 1 1000 >/dev/null
)
pass "status reports an untrusted or unsearchable status directory as an error"

reset_grant
(
  source "$library"
  install -d -m 0755 "$status_dir"
  TEST_BAD_PATH="$status_dir" assert_status 1 enable_locked 1000 15
  [[ ! -e $(rule_file 1000) && ! -e $marker ]]
  rm -rf "$status_dir"
  ln -s "$test_tmp/etc" "$status_dir"
  assert_status 1 enable_locked 1000 15
  [[ ! -e $(rule_file 1000) ]]
  assert_status 1 remove_status_locked 1000
  assert_status 1 cleanup_all_locked
  rm "$status_dir"
)
pass "an untrusted status directory blocks publication and marker removal"

reset_grant
for args in 'status --json extra' 'status --yaml' 'disable now'; do
  # shellcheck disable=SC2086
  assert_status 1 /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" $args 2>/dev/null
done
: >"$test_tmp/commands"
assert_status 3 /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" status >/dev/null
! grep -q '^sudo ' "$test_tmp/commands" || fail "status must not invoke sudo"
pass "public status needs no sudo and malformed subcommands are refused"

# A live grant lets disable revoke with no prompt, so it must go straight to
# the fixed internal action and still drop its authorization on the way out.
: >"$test_tmp/commands"
/usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" disable >"$test_tmp/public.log" 2>&1
grep -q "^sudo -N -- .* __disable $(/usr/bin/id -u)\$" "$test_tmp/commands" || fail "disable must call the internal revoke action"
! grep -q -e '__status' -e '^gum ' "$test_tmp/commands" || fail "disable must not inspect or prompt"
[[ $(tail -1 "$test_tmp/commands") == 'sudo -k' ]] || fail "disable must revoke its authorization on exit"
pass "public disable revokes non-interactively and drops its authorization"
