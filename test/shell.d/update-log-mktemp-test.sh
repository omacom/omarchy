#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

# omarchy-update used to hand script(1) the fixed path /tmp/omarchy-update.log.
# That shared name could collide with another user's file and block updates.
# Check that each update uses a unique private transcript, retains it for
# diagnosis, and preserves exec/signal behavior without touching a live log.

require_command script
require_command mktemp

FIXED_UPDATE="$ROOT/bin/omarchy-update"
FIXED_ANALYZE="$ROOT/bin/omarchy-update-analyze-logs"

test_tmp=$(mktemp -d)
created_logs=()
cleanup() {
  local log
  for log in "${created_logs[@]}"; do
    rm -f -- "$log"
  done
  rm -rf -- "$test_tmp"
}
trap cleanup EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/untrusted-tmp"
# An untrusted TMPDIR must not determine where script(1) reopens the log.
export TMPDIR="$test_tmp/untrusted-tmp"
# --- extract the fixed wrapper block verbatim from the shipped script ---
awk '/if \[\[ -z \$\{OMARCHY_UPDATE_LOGGED:-\} \]\]; then/{flag=1} flag{print} flag && /^fi$/{exit}' \
  "$FIXED_UPDATE" >"$test_tmp/wrapper.sh"
[[ -s $test_tmp/wrapper.sh ]] || fail "could not extract the update-logging wrapper from bin/omarchy-update"
grep -q 'mktemp' "$test_tmp/wrapper.sh" || fail "extracted wrapper does not create a private log"
grep -q 'OMARCHY_UPDATE_LOG_FILE' "$test_tmp/wrapper.sh" || fail "extracted wrapper does not export OMARCHY_UPDATE_LOG_FILE"

# Stub script(1): last argv word is the transcript. Capture the original
# process PID to prove the logging wrapper uses exec rather than waiting
# in a separate Bash process (which can change signal handling).
cat >"$test_tmp/bin/script" <<'STUB'
#!/bin/bash
set -euo pipefail
logfile="${@: -1}"
printf '%s\n' "$OMARCHY_UPDATE_LOG_FILE" >"$SANDBOX/captured-env-log"
printf '%s\n' "$logfile" >"$SANDBOX/captured-arg-log"
printf '%s\n' "$BASHPID" >"$SANDBOX/script-pid"
printf 'TRANSCRIPT-MARKER\n' >"$logfile"
exit "${SCRIPT_CHILD_RC:-0}"
STUB
chmod +x "$test_tmp/bin/script"

export SANDBOX="$test_tmp"
export PATH="$test_tmp/bin:$PATH"
# --- green: private logs persist and exec preserves signal/PID semantics ---
run_wrapper() {
  WRAPPER_RC=0
  (
    export PATH="$test_tmp/bin:/usr/bin:/bin"
    user_path="/usr/bin:/bin"
    set -- "$test_tmp/inner.sh"
    printf '%s\n' "$BASHPID" >"$SANDBOX/wrapper-pid"
    # shellcheck disable=SC1090
    source "$test_tmp/wrapper.sh"
  ) >"$test_tmp/wrapper-out" 2>"$test_tmp/wrapper-err" || WRAPPER_RC=$?
  WRAPPER_LOG=$(cat "$test_tmp/captured-arg-log")
  created_logs+=("$WRAPPER_LOG")
}

export SCRIPT_CHILD_RC=0
run_wrapper
(( WRAPPER_RC == 0 )) || fail "wrapper: successful update should exit 0" "status $WRAPPER_RC"
[[ $WRAPPER_LOG == /tmp/omarchy-update-log.* ]] || fail "wrapper: expected a unique system tmp log" "$WRAPPER_LOG"
[[ $WRAPPER_LOG != "$TMPDIR"/* ]] || fail "wrapper: must ignore an untrusted TMPDIR"
[[ $WRAPPER_LOG == "$(cat "$test_tmp/captured-env-log")" ]] || fail "wrapper: script and analyzer disagree on the log"
[[ -f $WRAPPER_LOG ]] || fail "wrapper: completed update must retain its log"
[[ $(stat -c %a "$WRAPPER_LOG") == 600 ]] || fail "wrapper: transcript file must be private"
grep -Fq 'TRANSCRIPT-MARKER' "$WRAPPER_LOG" || fail "wrapper: transcript content was lost"
grep -Fq "$WRAPPER_LOG" "$test_tmp/wrapper-err" || fail "wrapper: diagnostic does not name the retained log"
pass "wrapper: per-run private log is retained and discoverable"

[[ $(cat "$test_tmp/wrapper-pid") == "$(cat "$test_tmp/script-pid")" ]] ||
  fail "wrapper: script(1) must replace the wrapper process (exec)"
pass "wrapper: exec preserves process identity and signal behavior"

first_log=$WRAPPER_LOG
export SCRIPT_CHILD_RC=42
run_wrapper
(( WRAPPER_RC == 42 )) || fail "wrapper: logged failure exit status propagates" "status $WRAPPER_RC"
[[ -f $WRAPPER_LOG ]] || fail "wrapper: failed update must retain its transcript"
[[ $WRAPPER_LOG != "$first_log" ]] || fail "wrapper: two runs must not share a log"
grep -Fq "$WRAPPER_LOG" "$test_tmp/wrapper-err" || fail "wrapper: failed update must print its log path"
pass "wrapper: failure propagates and logs remain distinct"
export SCRIPT_CHILD_RC=0
# --- analyze-logs honors OMARCHY_UPDATE_LOG_FILE ---
fail_log="$test_tmp/fail.log"
printf 'Updating linux initcpios\nsome error\n' >"$fail_log"
out=$(OMARCHY_UPDATE_LOG_FILE="$fail_log" bash "$FIXED_ANALYZE" 2>&1)
[[ $out == *"may have failed"* ]] || fail "analyze-logs: expected the initramfs warning, got: $out"
pass "analyze-logs: warns on a failed initramfs run via OMARCHY_UPDATE_LOG_FILE"

ok_log="$test_tmp/ok.log"
printf 'Updating linux initcpios\nInitcpio image generation successful\n' >"$ok_log"
out=$(OMARCHY_UPDATE_LOG_FILE="$ok_log" bash "$FIXED_ANALYZE" 2>&1)
[[ -z $out ]] || fail "analyze-logs: unexpected output on a clean log: $out"
pass "analyze-logs: stays quiet on a clean log"

out=$(OMARCHY_UPDATE_LOG_FILE="$test_tmp/does-not-exist.log" bash "$FIXED_ANALYZE" 2>&1)
rc=$?
(( rc == 0 )) && [[ -z $out ]] || fail "analyze-logs: missing log should exit 0 quietly (rc=$rc, out=$out)"
pass "analyze-logs: missing log exits 0 quietly"
