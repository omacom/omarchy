#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

# omarchy-update used to hand script(1) the fixed path /tmp/omarchy-update.log.
# A pre-planted symlink there redirected the whole update transcript into an
# arbitrary file. The fix gives every run a private mktemp log and passes its
# path to the logged run through OMARCHY_UPDATE_LOG_FILE.

require_command script
require_command mktemp

FIXED_UPDATE="$ROOT/bin/omarchy-update"
FIXED_ANALYZE="$ROOT/bin/omarchy-update-analyze-logs"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"; rm -f /tmp/omarchy-update.log' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/tmp"
export TMPDIR="$test_tmp/tmp"

# --- red mechanism: the base's exact open call follows a planted symlink ---
# Base line (since replaced): script -qefc "$script_command" "/tmp/omarchy-update.log"
victim="$test_tmp/victim.txt"
printf 'victim-original\n' >"$victim"
ln -sf "$victim" /tmp/omarchy-update.log
script -qefc 'echo RED-MARKER' /tmp/omarchy-update.log >/dev/null 2>&1 || true
rm -f /tmp/omarchy-update.log
if grep -q RED-MARKER "$victim"; then
  pass "base mechanism: script(1) follows a planted symlink at /tmp/omarchy-update.log"
else
  fail "base mechanism: expected the planted symlink to be followed"
fi

# --- extract the fixed wrapper block verbatim from the shipped script ---
awk '/if \[\[ -z \$\{OMARCHY_UPDATE_LOGGED:-\} \]\]; then/{flag=1} flag{print} flag && /^fi$/{exit}' \
  "$FIXED_UPDATE" >"$test_tmp/wrapper.sh"
[[ -s $test_tmp/wrapper.sh ]] || fail "could not extract the update-logging wrapper from bin/omarchy-update"
grep -q 'mktemp' "$test_tmp/wrapper.sh" || fail "extracted wrapper does not create a private log"
grep -q 'OMARCHY_UPDATE_LOG_FILE' "$test_tmp/wrapper.sh" || fail "extracted wrapper does not export OMARCHY_UPDATE_LOG_FILE"

# Stub script(1): last argv word is the typescript. Real script(1) truncates
# through symlinks, so :> reproduces its open semantics faithfully. The child
# command itself is script's business, not the wrapper's, so the stub only
# records where the transcript would land.
cat >"$test_tmp/bin/script" <<'STUB'
#!/bin/bash
logfile="${@: -1}"
printf '%s\n' "$OMARCHY_UPDATE_LOG_FILE" >"$SANDBOX/captured-env-log"
printf '%s\n' "$logfile" >"$SANDBOX/captured-arg-log"
: >"$logfile"
echo "TRANSCRIPT-MARKER" >>"$logfile"
exit "${SCRIPT_CHILD_RC:-0}"
STUB
chmod +x "$test_tmp/bin/script"

export SANDBOX="$test_tmp"
export PATH="$test_tmp/bin:$PATH"
export SCRIPT_CHILD_RC=0

# --- green: planted symlink at the old fixed path is ignored, private log used ---
printf 'victim-original\n' >"$victim"
ln -sf "$victim" /tmp/omarchy-update.log

rc=0
(
  export PATH="$test_tmp/bin:/usr/bin:/bin"
  user_path="/usr/bin:/bin"
  set -- "$test_tmp/inner.sh"
  # shellcheck disable=SC1090
  source "$test_tmp/wrapper.sh"
) || rc=$?
rm -f /tmp/omarchy-update.log

(( rc == 0 )) || fail "fixed wrapper: expected exit 0, got $rc"
[[ $(cat "$victim") == "victim-original" ]] || fail "fixed wrapper: planted symlink victim was modified"
pass "fixed wrapper: planted symlink at the old fixed path is ignored"

arg_log=$(cat "$test_tmp/captured-arg-log")
env_log=$(cat "$test_tmp/captured-env-log")
[[ $arg_log == "$env_log" ]] || fail "fixed wrapper: script got '$arg_log' but env said '$env_log'"
[[ $arg_log == "$test_tmp"/tmp/omarchy-update-log.* ]] || fail "fixed wrapper: log is not a private mktemp file (got $arg_log)"
[[ $arg_log != "/tmp/omarchy-update.log" ]] || fail "fixed wrapper: still using the fixed /tmp path"
[[ ! -e $arg_log ]] || fail "fixed wrapper: private log was not cleaned up"
pass "fixed wrapper: transcript goes to a private mktemp log, cleaned up after"

# --- green: exit status of the logged run propagates ---
export SCRIPT_CHILD_RC=42
rc=0
(
  export PATH="$test_tmp/bin:/usr/bin:/bin"
  user_path="/usr/bin:/bin"
  set -- "$test_tmp/inner.sh"
  source "$test_tmp/wrapper.sh"
) || rc=$?
(( rc == 42 )) || fail "fixed wrapper: expected exit 42 from the logged run, got $rc"
pass "fixed wrapper: logged run exit status propagates"
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
