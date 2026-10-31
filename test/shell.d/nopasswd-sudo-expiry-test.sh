#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/passwordless-sudo-test.sh"

(
  source "$library"
  for minutes in 1 15 1440 00015; do valid_minutes "$minutes" || exit 1; done
  for minutes in 0 1441 -1 1m '' 18446744073709551617; do ! valid_minutes "$minutes" || exit 1; done
  for name in audituser 'buildbot$'; do valid_account_name "$name" || exit 1; done
  # Upper-case words are sudoers alias references, so ALICE must never publish.
  for name in 'a$b' '$' 'a b' 'a#b' Alice ALICE ALL aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa; do ! valid_account_name "$name" || exit 1; done
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
  grep -q '^sudo -n -N -l -l -- .* __status ' "$test_tmp/commands" || fail "status must inspect policy without authentication"
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
  TEST_ACCOUNT=ALICE assert_status 1 enable_locked 1000 15
  [[ ! -e $(rule_file 1000) ]]
)
pass "trailing-dollar accounts publish valid native policy and alias-shaped names never publish"

reset_grant
(
  source "$library"
  valid_duration permanent
  ! valid_duration forever || fail "invalid duration was accepted"
  enable_locked 1000 permanent
  read_grant 1000
  [[ $GRANT_NAME == audituser && -z $GRANT_DEADLINE ]]
  [[ $(stat -c '%a' "$(rule_file 1000 permanent)") == 440 ]]
  /usr/sbin/visudo -cf "$(rule_file 1000 permanent)" >/dev/null
  ! grep -q '^systemd-run ' "$test_tmp/commands" || fail "permanent grant started a timer"
  TEST_EXPIRED=1 status_locked 1000
  TEST_EXPIRED=1 expire_locked 1000
  cleanup_all_locked
  /usr/bin/systemd-tmpfiles --root="$test_tmp" --remove --boot --inline 'r! /etc/sudoers.d/99-omarchy-nopasswd-*'
  [[ -f $(rule_file 1000 permanent) ]]
  cleanup_uid_locked 1000
  assert_status 3 status_locked 1000
)
pass "permanent access has no timer, survives expiry and temporary cleanup, and can be disabled"

reset_grant
(
  source "$library"
  enable_locked 1000 15
  enable_locked 1000 permanent
  [[ ! -e $(rule_file 1000) && -e $(rule_file 1000 permanent) ]]
  TEST_EXPIRED=1 expire_locked 1000
  [[ -e $(rule_file 1000 permanent) ]]
  enable_locked 1000 60
  [[ -e $(rule_file 1000) && ! -e $(rule_file 1000 permanent) ]]
  TEST_EXPIRED=1 expire_locked 1000
  assert_status 3 status_locked 1000
  TEST_PUBLISH_FAIL=1 assert_status 1 enable_locked 1000 permanent
  [[ ! -e $(rule_file 1000 permanent) ]]
)
pass "switching duration replaces the prior policy and old callbacks preserve permanent access"

reset_grant
(
  source "$library"
  permanent=$(rule_file 1000 permanent)
  printf 'audituser ALL=(ALL) NOPASSWD: /usr/bin/true\n' >"$permanent"
  assert_status 2 status_locked 1000
  assert_status 1 enable_locked 1000 permanent
  assert_status 1 cleanup_uid_locked 1000
  [[ -e $permanent ]]
  rm "$permanent"
  enable_locked 1000 permanent
  TEST_BAD_PATH="$permanent" assert_status 2 status_locked 1000
)
pass "permanent policy rejects unsafe ownership and preserves administrator edits"

for choice in '15 minutes' '1 Hour' '1 Day' Permanently; do
  case "$choice" in
    '15 minutes') expected=15 ;;
    '1 Hour') expected=60 ;;
    '1 Day') expected=1440 ;;
    Permanently) expected=permanent ;;
  esac
  : >"$test_tmp/commands"
  TEST_CHOICE="$choice" TEST_CONFIRM_STATUS=0 /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" >"$test_tmp/public.log" 2>&1
  grep -q '^gum choose .*15 minutes 1 Hour 1 Day Permanently$' "$test_tmp/commands"
  grep -q "^sudo -N -- .* __enable .* $expected$" "$test_tmp/commands"
  [[ $(tail -1 "$test_tmp/commands") == 'sudo -k' ]]
  if [[ $expected == permanent ]]; then
    grep -q 'remain enabled across reboots until you disable it' "$test_tmp/public.log"
    ! grep -q 'automatically disable' "$test_tmp/public.log" || fail "permanent grant claims automatic expiry"
  fi
done
pass "each duration choice dispatches its exact grant duration with permanent-specific copy"

: >"$test_tmp/commands"
assert_status 130 env TEST_CHOICE_CANCEL=1 /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" >"$test_tmp/public.log" 2>&1
! grep -q '__enable\|^gum confirm ' "$test_tmp/commands" || fail "cancelled picker continued enablement"
[[ $(tail -1 "$test_tmp/commands") == 'sudo -k' ]]
: >"$test_tmp/commands"
TEST_STATUS=0 /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" >"$test_tmp/public.log" 2>&1
! grep -q '^gum ' "$test_tmp/commands" || fail "disabling access offered a picker"
grep -q '__disable ' "$test_tmp/commands"
pass "cancelling the picker grants nothing and active access still toggles off"

for confirm_status in 0 1; do
  : >"$test_tmp/commands"
  TEST_STATUS=0 TEST_CONFIRM_STATUS=$confirm_status /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" permanent >"$test_tmp/public.log" 2>&1
  grep -q '^gum confirm Enable passwordless sudo permanently?' "$test_tmp/commands"
  if (( confirm_status == 0 )); then
    grep -q '__enable .* permanent$' "$test_tmp/commands"
  else
    ! grep -q '__enable ' "$test_tmp/commands" || fail "declining permanent access still enabled it"
  fi
done
pass "changing active access to permanent always requires confirmation"

reset_grant
(
  source "$library"
  enable_locked 1000 15
  TEST_REQUIRE_EXISTING_TARGET=1 enable_locked 1000 60
  cleanup_uid_locked 1000
  enable_locked 01000 permanent
  status_locked 1000
  [[ -e $(rule_file 1000 permanent) ]]
  [[ ! -e $test_tmp/etc/sudoers.d/99-omarchy-permanent-nopasswd-01000 ]]
  cleanup_uid_locked 1000
  assert_status 3 status_locked 01000
)
pass "renewal replaces the existing rule atomically and zero-padded UIDs share one policy"


for policy in '    Options: !authenticate' '    Options: authenticate'; do
  : >"$test_tmp/commands"
  expected=1
  [[ $policy != *'!authenticate'* ]] || expected=0
  assert_status "$expected" env TEST_POLICY="$policy" /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" --active
  [[ $(wc -l <"$test_tmp/commands") == 1 ]]
  grep -q '^sudo -n -N -l -l -- .* __status ' "$test_tmp/commands"
done
assert_status 1 env TEST_POLICY_FAILURE=1 /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" --active
pass "menu probe reads policy tags without executing a privileged action or changing the timestamp"

for status in 0 3; do
  : >"$test_tmp/commands"
  TEST_STATUS=$status /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" --disable >"$test_tmp/public.log" 2>&1
  ! grep -q '^gum\|__enable ' "$test_tmp/commands" || fail "explicit disable offered enablement"
  if (( status == 0 )); then
    grep -q '__disable ' "$test_tmp/commands"
  fi
done
pass "explicit disable never enables access even when a displayed grant has expired"

: >"$test_tmp/commands"
TEST_STATUS=3 TEST_CHOICE='15 minutes' TEST_CONFIRM_STATUS=0 /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" >"$test_tmp/public.log" 2>&1
[[ $(grep -c '^sudo -N -- ' "$test_tmp/commands") == 1 ]] || fail "enable must authenticate exactly one sudo call"
grep -q '^sudo -N -- .* __enable .* 15$' "$test_tmp/commands"
! grep -q '^sudo -n -N -- .* __status ' "$test_tmp/commands" || fail "inactive flow attempted root status"
[[ $(tail -1 "$test_tmp/commands") == 'sudo -k' ]]
pass "enabling from inactive policy has exactly one password-capable sudo invocation"

: >"$test_tmp/commands"
TEST_STATUS=0 /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" --disable >"$test_tmp/public.log" 2>&1
grep -q '^sudo -n -N -- .* __disable ' "$test_tmp/commands" || fail "disable must refuse interactive authentication"
! grep -q '^sudo -N -- ' "$test_tmp/commands" || fail "disable attempted an interactive sudo command"
pass "disabling active access is fully noninteractive"

for duration in permanent 15; do
  reset_grant
  (
    source "$library"
    if [[ $duration == permanent ]]; then
      enable_locked 1000 15
    else
      enable_locked 1000 permanent
    fi
    assert_status 137 env TEST_KILL_AFTER_PUBLISH=1 TEST_EUID=0 SUDO_UID=1000 /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" __enable 1000 "$duration"
    [[ -f $(rule_file 1000) && -f $(rule_file 1000 permanent) ]]
    status_locked 1000
    TEST_EXPIRED=1 expire_locked 1000
    [[ -f $(rule_file 1000 permanent) ]]
    cleanup_uid_locked 1000
    assert_status 3 status_locked 1000
  )
done
pass "SIGKILL during either duration switch leaves access inspectable and revocable without expiring permanent policy"

reset_grant
(
  source "$library"
  enable_locked 1000 permanent
  timed=$(rule_file 1000)
  printf 'otheruser ALL=(ALL) NOTAFTER=99991231235959Z NOPASSWD: ALL\n' >"$timed"
  assert_status 2 read_grant 1000
  assert_status 1 enable_locked 1000 15
  printf 'audituser ALL=(ALL) NOTAFTER=99991231235959Z NOPASSWD: ALL\n' >"$timed"
  TEST_BAD_PATH="$timed" assert_status 2 read_grant 1000
  rm "$timed"
  ln -s "$(rule_file 1000 permanent)" "$timed"
  assert_status 2 read_grant 1000
  rm "$timed"
  printf 'audituser ALL=(ALL) NOTAFTER=99991231235959Z NOPASSWD: ALL\n' >"$timed"
  enable_locked 1000 15
  [[ -f $timed && ! -e $(rule_file 1000 permanent) ]]
)
pass "paired policy recovery rejects mismatched or unsafe rules and allows a complete duration change"

: >"$test_tmp/commands"
TEST_POLICY_FAILURE=1 TEST_STATUS=0 /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" --disable >"$test_tmp/public.log" 2>&1
grep -q '^sudo -n -N -- .* __disable ' "$test_tmp/commands"
! grep -q '^gum\|^sudo -N -- ' "$test_tmp/commands" || fail "listpw=always disable prompted"
TEST_POLICY_FAILURE=1 TEST_STATUS=0 /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" --active
assert_status 1 env TEST_POLICY_FAILURE=1 TEST_STATUS=1 /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" --active
: >"$test_tmp/commands"
TEST_POLICY_FAILURE=1 TEST_STATUS=1 TEST_CONFIRM_STATUS=0 /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" 15 >"$test_tmp/public.log" 2>&1
[[ $(grep -c '^sudo -N -- ' "$test_tmp/commands") == 1 ]] || fail "listing failure must leave one enable authentication"
grep -q '^sudo -N -- .* __enable .* 15$' "$test_tmp/commands"
: >"$test_tmp/commands"
assert_status 1 env TEST_POLICY_FAILURE=1 TEST_STATUS=2 /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" 15 >"$test_tmp/public.log" 2>&1
! grep -q '^gum\|__enable ' "$test_tmp/commands" || fail "unsafe grant was offered enablement"
pass "password-required listings do not block enabling, disabling, or active detection"

: >"$test_tmp/commands"
TEST_POLICY_FAILURE=1 TEST_STATUS=2 /usr/bin/bash -p "$test_tmp/omarchy-sudo-passwordless" --active
grep -q '^sudo -kn -- .* __status ' "$test_tmp/commands" || fail "fallback probe must ignore cached credentials"
(
  source "$library"
  with_root_lock() { return 1; }
  verify_sudo_caller() { return 0; }
  assert_status 2 root_dispatch __status 1000
)
pass "status lock failures remain inspection errors and an authenticated unsafe grant keeps its warning"
