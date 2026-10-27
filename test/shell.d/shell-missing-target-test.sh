#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
run_dir="$test_tmp/run"
notify_dir="$test_tmp/notify"
notify_log="$test_tmp/notifications"
mkdir -p "$stub_bin" "$run_dir"

cat >"$stub_bin/qs" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$FAKE_QS_LOG"
case ${FAKE_QS_OUTPUT:-ok} in
  not-running) exit 1 ;;
  *) printf '%s\n' "$FAKE_QS_OUTPUT" ;;
esac
SH

cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$FAKE_NOTIFY_LOG"
[[ ${FAKE_NOTIFY_FAIL:-0} == 1 ]] && exit 1
SH

chmod 0755 "$stub_bin/qs" "$stub_bin/omarchy-notification-send"

export FAKE_QS_LOG="$test_tmp/qs.log"
export FAKE_NOTIFY_LOG="$notify_log"

shell_call() {
  PATH="$stub_bin:$ROOT/bin:$PATH" \
    OMARCHY_PATH="$ROOT" \
    XDG_RUNTIME_DIR="$run_dir" \
    OMARCHY_SHELL_NOTIFY_DIR="$notify_dir" \
    OMARCHY_SHELL_NOTIFY_INTERVAL="${NOTIFY_INTERVAL:-300}" \
    OMARCHY_SHELL_IPC_TIMEOUT=0.1s \
    "$ROOT/bin/omarchy-shell" "$@"
}

notification_count() {
  [[ -f $notify_log ]] || {
    printf '0\n'
    return
  }
  wc -l <"$notify_log"
}

wait_for_notifications() {
  local wanted="$1" i

  for ((i = 0; i < 100; i++)); do
    (( $(notification_count) >= wanted )) && return 0
    sleep 0.02
  done

  return 1
}

output=$(FAKE_QS_OUTPUT="Function not found." shell_call omarchy.dock apps 2>&1) &&
  fail "a missing shell function still fails the call"
[[ $output == "Function not found." ]] || fail "the missing function is still reported on stderr" "$output"
wait_for_notifications 1 || fail "a missing function raises a notification"
grep -F 'Omarchy shell action unavailable' "$notify_log" >/dev/null ||
  fail "the notification names the unavailable shell action"
grep -F 'omarchy.dock.apps' "$notify_log" >/dev/null ||
  fail "the notification names the missing target and method"
pass "a missing shell function is visible in a notification"

FAKE_QS_OUTPUT="Function not found." shell_call omarchy.dock apps >/dev/null 2>&1 || true
sleep 0.2
[[ $(notification_count) == "1" ]] || fail "repeating the same miss does not notify again"
FAKE_QS_OUTPUT="Function not found." shell_call omarchy.dock settings >/dev/null 2>&1 || true
wait_for_notifications 2 || fail "a different missing function notifies on its own"
pass "missing shell actions are rate-limited per target and method"

FAKE_QS_OUTPUT="Target not found." shell_call omarchy.missing ping >/dev/null 2>&1 || true
wait_for_notifications 3 || fail "a missing target raises a notification"
grep -F 'omarchy.missing.ping' "$notify_log" >/dev/null ||
  fail "a missing target names the missing target and method"
pass "a missing shell target is visible in a notification"

FAKE_QS_OUTPUT="Function not found." shell_call -q omarchy.quiet apps >/dev/null 2>&1 ||
  fail "a quiet miss still succeeds"
sleep 0.2
[[ $(notification_count) == "3" ]] || fail "quiet best-effort calls never notify"
pass "quiet shell calls stay silent"

FAKE_QS_OUTPUT="Too few arguments provided (expected 2)" shell_call omarchy.argcheck apps >/dev/null 2>&1 || true
sleep 0.2
[[ $(notification_count) == "3" ]] || fail "an argument error is not a missing plugin"
pass "shell argument errors do not notify"

FAKE_QS_OUTPUT=not-running shell_call omarchy.stopped apps >/dev/null 2>&1 || true
sleep 0.2
[[ $(notification_count) == "3" ]] || fail "a stopped shell does not notify about a missing target"
pass "a stopped shell does not notify"

FAKE_QS_OUTPUT=ok shell_call shell ping >/dev/null 2>&1 ||
  fail "a working shell still answers"
[[ $(notification_count) == "3" ]] || fail "a successful call does not notify"

output=$(FAKE_NOTIFY_FAIL=1 NOTIFY_INTERVAL=0 FAKE_QS_OUTPUT="Function not found." \
  shell_call omarchy.dock apps 2>&1) && fail "a missing function still fails when the notifier does"
[[ $output == "Function not found." ]] || fail "the IPC answer is unchanged by the notifier" "$output"
wait_for_notifications 4 || fail "a failing notifier is still attempted"
pass "a failing notification never changes the IPC result"
