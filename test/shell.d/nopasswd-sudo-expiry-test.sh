#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/passwordless-sudo-test.sh"

(
  source "$library"
  for minutes in 1 15 1440 00015; do valid_minutes "$minutes" || exit 1; done
  for minutes in 0 1441 -1 1m '' 18446744073709551617; do ! valid_minutes "$minutes" || exit 1; done
  for name in audituser 'buildbot$'; do valid_account_name "$name" || exit 1; done
  for name in 'a$b' '$' aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa; do ! valid_account_name "$name" || exit 1; done
  ! valid_uid 18446744073709551617
)
pass "duration and account validation retains bounded inputs and trailing-dollar usernames"

(
  source "$library"
  assert_status 2 root_dispatch __status 1000
  assert_status 2 env TEST_EUID=0 SUDO_UID=1001 /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" __status 1000
  assert_status 3 env TEST_EUID=0 SUDO_UID=1000 /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" __status 1000
)
pass "internal actions reject missing root and mismatched sudo identity"

for status in 1 2 3; do
  : >"$test_tmp/commands"
  result=0
  TEST_STATUS=$status /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" 15 >"$test_tmp/public.log" 2>&1 || result=$?
  if (( status == 3 )); then
    (( result == 0 )) && grep -q '^gum confirm ' "$test_tmp/commands" || fail "inactive status must allow confirmation"
  else
    (( result != 0 )) && ! grep -q '^gum ' "$test_tmp/commands" || fail "inspection errors must not offer enablement"
  fi
  grep -q '^sudo -N -- .* __status ' "$test_tmp/commands" || fail "status must not publish reusable authorization"
  [[ $(tail -1 "$test_tmp/commands") == 'sudo -k' ]] || fail "public exit must revoke its authorization"
done
pass "public status distinguishes inactive from errors and revokes authorization on exit"

printf ': >"$TEST_STARTUP_MARKER"\nset -o privileged\nunset BASH_ENV\n' >"$test_tmp/startup"
: >"$test_tmp/commands"
if TEST_STARTUP_MARKER="$test_tmp/startup-ran" BASH_ENV="$test_tmp/startup" bash "$test_tmp/omarchy-sudo-passwordless" -p >/dev/null 2>&1; then
  fail "ordinary Bash with a decoy -p was accepted"
fi
[[ -f $test_tmp/startup-ran && ! -s $test_tmp/commands ]] || fail "startup rejection must precede sudo"
pass "startup validation rejects ordinary Bash before authorization"

(
  source "$library"
  enable_locked 1000 15
  read_grant 1000
  [[ $GRANT_NAME == audituser && $(stat -c '%a' "$(rule_file 1000)") == 440 ]]
  /usr/sbin/visudo -cf "$(rule_file 1000)" >/dev/null
  expiry=$(sed -n 's/^systemd-run .*--on-calendar=@\([0-9]*\).*$/\1/p' "$test_tmp/commands" | tail -1)
  [[ $GRANT_DEADLINE == "$(/usr/bin/date -u -d "@$expiry" +%Y%m%d%H%M%SZ)" ]]
  if [[ -n ${OMARCHY_TEST_SUDOERS:-} ]]; then
    [[ -x $OMARCHY_TEST_SUDOERS ]] || fail "OMARCHY_TEST_SUDOERS must name an executable"
    printf 'root:x:0:0:root:/root:/bin/bash\naudituser:x:1000:1000:Test:/nonexistent:/bin/bash\n' >"$test_tmp/passwd"
    printf 'root:x:0:\naudituser:x:1000:\n' >"$test_tmp/group"
    { printf 'audituser ALL=(ALL) ALL\n'; cat "$(rule_file 1000)"; } >"$test_tmp/policy"
    for offset in -1 1; do
      when=$(/usr/bin/date -u -d "@$((expiry + offset))" +%Y%m%d%H%M%SZ)
      "$OMARCHY_TEST_SUDOERS" -p "$test_tmp/passwd" -P "$test_tmp/group" -T "$when" audituser /usr/bin/true <"$test_tmp/policy" >"$test_tmp/policy-result"
      if (( offset < 0 )); then
        ! grep -q 'Password required' "$test_tmp/policy-result" || fail "native policy requires a password before expiry"
      else
        grep -q 'Password required' "$test_tmp/policy-result" || fail "native policy remains passwordless after expiry"
      fi
    done
    pass "native sudoers evaluation requires authentication after the generated deadline"
  fi
  assert_status 0 status_locked 1000
  TEST_INACTIVE_TIMER=1 assert_status 0 status_locked 1000
  [[ ! -e $test_tmp/var/lib/omarchy/sudo-passwordless ]]
  ! compgen -G "$test_tmp/etc/sudoers.d/.omarchy-nopasswd.*"
)
pass "one complete mode-0440 sudoers rule holds the deadline with no separate grant state"

(
  source "$library"
  before=$(cat "$(rule_file 1000)")
  expire_locked 1000 omarchy-nopasswd-expire-1000-ffffffffffffffffffffffffffffffff
  [[ $(cat "$(rule_file 1000)") == "$before" ]]
  enable_locked 1000 30
  renewed=$(cat "$(rule_file 1000)")
  [[ $renewed != "$before" ]]
  expire_locked 1000
  [[ $(cat "$(rule_file 1000)") == "$renewed" ]]
  TEST_EXPIRED=1 expire_locked 1000
  [[ ! -e $(rule_file 1000) ]]
)
pass "legacy and current callbacks preserve renewed grants and remove expired ones"

(
  source "$library"
  enable_locked 1000 1
  assert_status 2 env TEST_EXPIRED=1 TEST_DELETE_FAIL=1 TEST_EUID=0 SUDO_UID=1000 /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" __status 1000
  [[ -e $(rule_file 1000) ]]
  TEST_EXPIRED=1 assert_status 3 status_locked 1000
  [[ ! -e $(rule_file 1000) ]]
)
pass "expired status reports cleanup failure separately from confirmed inactivity"

for failure in TEST_TIMER_FAIL TEST_INACTIVE_TIMER TEST_PUBLISH_FAIL TEST_POST_PUBLISH_FAIL TEST_CANCEL_ENABLE; do
  reset_grant
  expected=1
  if [[ $failure == "TEST_CANCEL_ENABLE" ]]; then expected=143; fi
  (
    source "$library"
    enable_locked 1000 15
    assert_status "$expected" env "$failure=1" TEST_EUID=0 SUDO_UID=1000 /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" __enable 1000 30
    [[ ! -e $(rule_file 1000) ]]
  )
done
pass "timer, publication, post-publication and cancellation failures revoke renewed access"

reset_grant
(
  source "$library"
  TEST_POST_PUBLISH_FAIL=1 TEST_DELETE_FAIL=1 assert_status 1 enable_locked 1000 15
  [[ -e $(rule_file 1000) ]]
  ! grep -q '^systemctl stop ' "$test_tmp/commands"
)
pass "failed policy deletion retains the timer and reports failure"

reset_grant
(
  source "$library"
  printf 'audituser ALL=(ALL) NOPASSWD: /usr/bin/true\n' >"$(rule_file 1000)"
  cp "$(rule_file 1000)" "$test_tmp/admin-rule"
  assert_status 2 status_locked 1000
  assert_status 1 enable_locked 1000 15
  assert_status 1 cleanup_uid_locked 1000
  cmp "$(rule_file 1000)" "$test_tmp/admin-rule"
  rm "$(rule_file 1000)"
  ln -s "$test_tmp/admin-rule" "$(rule_file 1000)"
  assert_status 2 status_locked 1000
  assert_status 1 cleanup_uid_locked 1000
  [[ -L $(rule_file 1000) ]]
)
pass "grant operations preserve administrator policies and reject symlinks"

reset_grant
(
  source "$library"
  TEST_BAD_PATH="$test_tmp/etc/sudoers.d" assert_status 1 enable_locked 1000 15
  [[ ! -e $(rule_file 1000) ]]
  rm "$PACKAGE_HOOK"
  assert_status 1 enable_locked 1000 15
)
pass "publication requires trusted paths and the packaged cleanup hook"

reset_grant
cp "$ROOT/default/libalpm/hooks/05-omarchy-passwordless-revoke.hook" "$test_tmp/hooks/"
(
  source "$library"
  TEST_ACCOUNT='buildbot$' enable_locked 1000 15
  read_grant 1000
  [[ $GRANT_NAME == 'buildbot$' ]]
  /usr/sbin/visudo -cf "$(rule_file 1000)" >/dev/null
  cleanup_uid_locked 1000
  [[ ! -e $(rule_file 1000) ]]
)
pass "trailing-dollar accounts publish and revoke valid native policy"
