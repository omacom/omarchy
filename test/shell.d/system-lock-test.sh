#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

real_timeout=$(command -v timeout)

setup_scenario() {
  scenario_dir="$tmpdir/$1"
  mock_bin="$scenario_dir/bin"
  call_log="$scenario_dir/calls"
  notify_log="$scenario_dir/notifications"
  mkdir -p "$mock_bin" "$scenario_dir/home" "$scenario_dir/runtime"
  : >"$call_log"
  : >"$notify_log"

  for command in hyprctl pkill pidwait; do
    cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >>"$CALL_LOG"
SH
  done

  cat >"$mock_bin/timeout" <<'SH'
#!/bin/bash
printf 'timeout %s\n' "$*" >>"$CALL_LOG"
exec "$REAL_TIMEOUT" "$@"
SH

  cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash
printf 'shell %s\n' "$*" >>"$CALL_LOG"
if [[ $* == "lock lock" ]]; then
  case $SCENARIO in
    missing_pam) echo missing-pam ;;
    refused) echo failed ;;
    unexpected) echo unknown ;;
    nonzero) echo ok; exit 7 ;;
    no_shell) echo "omarchy-shell is not running" >&2; exit 1 ;;
    stalled_request) exec sleep 20 ;;
    *) echo ok ;;
  esac
elif [[ $* == "lock status" ]]; then
  case $SCENARIO in
    delayed)
      polls=0
      [[ -f $STATE_DIR/polls ]] && read -r polls <"$STATE_DIR/polls"
      (( ++polls ))
      echo "$polls" >"$STATE_DIR/polls"
      case $polls in
        1) ;;
        2) echo 'invalid json' ;;
        3) printf '{"secure":false}\n{"secure":true}\n' ;;
        4) echo '{"secure":"true","locked":true}' ;;
        5) echo '{"secure":false,"locked":true,"requested":true,"pending":true}' ;;
        *) echo '{"secure":true}'; echo SECURE >>"$CALL_LOG" ;;
      esac
      ;;
    never_secure) echo '{"secure":false,"locked":true,"requested":true}' ;;
    stalled_status) exec sleep 20 ;;
    failed_status) echo '{"secure":true}'; exit 1 ;;
    *) echo '{"secure":true}'; echo SECURE >>"$CALL_LOG" ;;
  esac
fi
SH

  cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$NOTIFY_LOG"
[[ ${STALL_NOTIFICATION:-0} == "1" ]] && exec sleep 20
exit 0
SH

  cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
[[ ${ONEPASSWORD_RUNNING:-0} == "1" ]]
SH

  cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == "1password" ]]
SH

  cat >"$mock_bin/1password" <<'SH'
#!/bin/bash
printf '1password %s\n' "$*" >>"$CALL_LOG"
touch "$STATE_DIR/password_locked"
SH
  chmod +x "$mock_bin"/*
}

run_lock() {
  local start_us=${EPOCHREALTIME//[!0-9]/}
  set +e
  PATH="$mock_bin:$PATH" HOME="$scenario_dir/home" OMARCHY_PATH="$ROOT" \
    XDG_RUNTIME_DIR="$scenario_dir/runtime" CALL_LOG="$call_log" \
    NOTIFY_LOG="$notify_log" STATE_DIR="$scenario_dir" REAL_TIMEOUT="$real_timeout" \
    SCENARIO="$1" ONEPASSWORD_RUNNING="${2:-0}" STALL_NOTIFICATION="${3:-0}" \
    "$real_timeout" 9s "$ROOT/bin/omarchy-system-lock" \
    >"$scenario_dir/stdout" 2>"$scenario_dir/stderr"
  exit_status=$?
  set -e
  elapsed_us=$((10#${EPOCHREALTIME//[!0-9]/} - 10#$start_us))

  (( exit_status != 124 && exit_status != 137 )) ||
    fail "system lock terminates within its own deadline" "scenario: $1"
}

assert_failed() {
  (( exit_status != 0 )) || fail "$1 returns failure"
  rg -q 'could not confirm a secure session lock' "$scenario_dir/stderr" ||
    fail "$1 explains failure on stderr"
  rg -q 'Screen lock failed' "$notify_log" ||
    fail "$1 sends a desktop warning"
  if rg -q '^(hyprctl|pkill|pidwait|1password) ' "$call_log"; then
    fail "$1 does not run post-lock actions without a secure lock" "$(<"$call_log")"
  fi
  pass "$1 fails visibly without running post-lock actions"
}

for scenario in missing_pam refused unexpected nonzero no_shell; do
  setup_scenario "$scenario"
  run_lock "$scenario" 1
  assert_failed "$scenario"
  if rg -q '^shell lock status$' "$call_log"; then
    fail "$scenario does not poll after an unaccepted request"
  fi
done

# Empty or malformed replies, extra JSON documents, a truthy string, and a
# requested/pending lock must all keep the command waiting. Only the
# compositor's secure boolean in a single status reply permits completion.
setup_scenario delayed
run_lock delayed 1
(( exit_status == 0 )) || fail "system lock succeeds once secure" "exit: $exit_status"
[[ $(<"$scenario_dir/polls") == "6" ]] ||
  fail "system lock waits for secure true rather than a requested lock"
[[ ! -s $notify_log ]] || fail "system lock does not warn after success"
secure_line=$(rg -n '^SECURE$' "$call_log")
keyboard_line=$(rg -n '^hyprctl switchxkblayout all 0$' "$call_log")
(( ${secure_line%%:*} < ${keyboard_line%%:*} )) ||
  fail "system lock resets the keyboard only after securing the session"
pass "system lock waits for confirmed security before resetting the keyboard"

# The password manager helper is asynchronous; give the fixture a bounded
# chance to finish without inheriting any live user's password-manager state.
for (( attempt = 0; attempt < 100; attempt++ )); do
  [[ -e $scenario_dir/password_locked ]] && break
  sleep 0.01
done
rg -q '^1password --lock$' "$call_log" || fail "system lock still locks 1Password"
pass "system lock still locks 1Password"

mapfile -t shutdown < <(rg '^(pkill|pidwait) |^timeout 1s pidwait' "$call_log")

[[ ${shutdown[0]} == "pkill -x ttfx" ]] ||
  fail "system lock stops ttfx before closing its terminal" "calls: ${shutdown[*]}"
[[ ${shutdown[1]} == "timeout 1s pidwait -x ttfx" ]] ||
  fail "system lock waits for ttfx to exit" "calls: ${shutdown[*]}"
[[ ${shutdown[2]} == "pidwait -x ttfx" ]] ||
  fail "system lock runs the bounded ttfx wait" "calls: ${shutdown[*]}"
[[ ${shutdown[3]} == "pkill -f [o]rg.omarchy.screensaver" ]] ||
  fail "system lock closes the screensaver terminal after ttfx exits" "calls: ${shutdown[*]}"
pass "system lock waits for ttfx before closing its terminal"

setup_scenario never_secure
run_lock never_secure
assert_failed "a session that never secures"
(( elapsed_us >= 4500000 && elapsed_us < 6500000 )) ||
  fail "system lock gives up after its five-second security budget" "elapsed: ${elapsed_us}us"
pass "system lock bounds the wait for a session that never secures"

for scenario in stalled_request stalled_status failed_status; do
  setup_scenario "$scenario"
  run_lock "$scenario"
  assert_failed "$scenario"
  (( elapsed_us < 2500000 )) ||
    fail "$scenario stays within the IPC timeout" "elapsed: ${elapsed_us}us"
done

setup_scenario stalled_notification
run_lock missing_pam 0 1
assert_failed "a stalled desktop notification"
(( elapsed_us < 2500000 )) ||
  fail "system lock bounds the failure notification" "elapsed: ${elapsed_us}us"
pass "system lock bounds the failure notification"
