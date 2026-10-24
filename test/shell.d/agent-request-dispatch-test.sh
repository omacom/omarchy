#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
dispatch_log="$test_tmp/dispatch.log"
launch_log="$test_tmp/launch.log"
mkdir -p "$mock_bin" "$test_home/.config/omarchy/agents" "$test_home/.config/omarchy/defaults"

printf 'claude\n' >"$test_home/.config/omarchy/defaults/agent"

cat >"$mock_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
exit "${OMARCHY_TEST_MISSING_STATUS:-1}"
SH

cat >"$mock_bin/omarchy-launch-tui" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_LAUNCH_LOG"
SH

cat >"$mock_bin/claude" <<'SH'
#!/bin/bash
printf '%s\0' claude "$@" >"$OMARCHY_TEST_LAUNCH_LOG"
SH

chmod +x "$mock_bin/omarchy-cmd-missing" "$mock_bin/omarchy-launch-tui" "$mock_bin/claude"

run_agent() {
  HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" \
    OMARCHY_TEST_LAUNCH_LOG="$launch_log" \
    OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
    "$ROOT/bin/omarchy-agent" "$@"
}

assert_launch() {
  python3 - "$launch_log" "$@" <<'PYTEST'
import pathlib, sys
actual = pathlib.Path(sys.argv[1]).read_bytes().split(b'\0')
expected = [arg.encode() for arg in sys.argv[2:]] + [b'']
assert actual == expected, (actual, expected)
PYTEST
}

# No dispatcher: prompted launch still reaches the harness.
: >"$launch_log"
run_agent --inline --prompt 'review this; echo $(whoami)'
assert_launch 'claude' '--permission-mode' 'auto' '--' 'review this; echo $(whoami)' ||
  fail "prompted launch without a dispatcher still reaches the default harness" "$(tr '\0' ' ' <"$launch_log")"
pass "prompted launch without a dispatcher still reaches the default harness"

# Promptless launch never consults a dispatcher even when one is installed.
cat >"$test_home/.config/omarchy/agents/request-dispatch" <<'SH'
#!/bin/bash
printf 'ran\n' >>"$OMARCHY_TEST_DISPATCH_LOG"
exit 0
SH
chmod +x "$test_home/.config/omarchy/agents/request-dispatch"
: >"$dispatch_log"
: >"$launch_log"
run_agent --inline
[[ ! -s $dispatch_log ]] || fail "promptless launch consulted the request dispatcher"
assert_launch 'claude' '--permission-mode' 'auto' ||
  fail "promptless launch still reaches the default harness" "$(tr '\0' ' ' <"$launch_log")"
pass "promptless launch ignores the request dispatcher"

# A dispatcher that accepts owns the request: prompt on stdin, never on argv.
cat >"$test_home/.config/omarchy/agents/request-dispatch" <<'SH'
#!/bin/bash
prompt=$(cat)
{
  printf 'argv:'
  printf ' %q' "$@"
  printf '\n'
  printf 'prompt:%s\n' "$prompt"
} >>"$OMARCHY_TEST_DISPATCH_LOG"
# Refuse to claim if the prompt leaked onto argv.
for arg in "$@"; do
  [[ $arg == *'$(whoami)'* ]] && exit 2
done
exit 0
SH
chmod +x "$test_home/.config/omarchy/agents/request-dispatch"
: >"$dispatch_log"
: >"$launch_log"
run_agent --inline --prompt 'review this; echo $(whoami)'
grep -Fq 'argv: --fallback-agent claude --cwd' "$dispatch_log" ||
  fail "dispatcher receives fallback agent and cwd on argv" "$(cat "$dispatch_log")"
grep -Fq 'prompt:review this; echo $(whoami)' "$dispatch_log" ||
  fail "dispatcher receives the prompt on stdin" "$(cat "$dispatch_log")"
[[ ! -s $launch_log ]] ||
  fail "accepted dispatcher still launched the fallback harness" "$(tr '\0' ' ' <"$launch_log")"
pass "accepted dispatcher owns the prompted request"

# An accepting dispatcher does not require the fallback to be installed.
: >"$launch_log"
OMARCHY_TEST_MISSING_STATUS=0 run_agent --inline --prompt 'handled elsewhere'
[[ ! -s $launch_log ]] || fail "missing fallback was launched after acceptance"
pass "dispatcher accepts with an unavailable fallback"

# Failure after dispatch may mean work already started. Never retry it here.
for failure in 1 127 143; do
  cat >"$test_home/.config/omarchy/agents/request-dispatch" <<SH
#!/bin/bash
cat >/dev/null
exit $failure
SH
  : >"$launch_log"
  if run_agent --inline --prompt 'do not duplicate'; then
    fail "dispatcher failure was reported as success"
  else
    actual_status=$?
    [[ $actual_status == "$failure" ]] || fail "dispatcher status was lost"
  fi
  [[ ! -s $launch_log ]] || fail "failed dispatcher launched duplicate work"
done
pass "dispatcher failures stop without fallback"

# A clean decline falls through to the harness.
cat >"$test_home/.config/omarchy/agents/request-dispatch" <<'SH'
#!/bin/bash
cat >/dev/null
exit 3
SH
chmod +x "$test_home/.config/omarchy/agents/request-dispatch"
: >"$launch_log"
run_agent --inline --prompt 'please handle'
assert_launch 'claude' '--permission-mode' 'auto' '--' 'please handle' ||
  fail "declined dispatcher does not fall through to the harness" "$(tr '\0' ' ' <"$launch_log")"
pass "declined dispatcher falls through to the default harness"

# Non-executable hooks are ignored.
cat >"$test_home/.config/omarchy/agents/request-dispatch" <<'SH'
#!/bin/bash
printf 'ran\n' >>"$OMARCHY_TEST_DISPATCH_LOG"
exit 0
SH
chmod a-x "$test_home/.config/omarchy/agents/request-dispatch"
: >"$dispatch_log"
: >"$launch_log"
run_agent --inline --prompt 'noexec'
[[ ! -s $dispatch_log ]] || fail "non-executable dispatcher was consulted"
assert_launch 'claude' '--permission-mode' 'auto' '--' 'noexec' ||
  fail "non-executable dispatcher blocked the fallback" "$(tr '\0' ' ' <"$launch_log")"
pass "non-executable dispatcher is ignored"

# Follow a real executable owned by another uid: exercise Bash's actual -O test.
if [[ -f /usr/bin/true && -x /usr/bin/true && ! -O /usr/bin/true ]]; then
  rm "$test_home/.config/omarchy/agents/request-dispatch"
  ln -s /usr/bin/true "$test_home/.config/omarchy/agents/request-dispatch"
  : >"$launch_log"
  run_agent --inline --prompt 'other-owner'
  assert_launch 'claude' '--permission-mode' 'auto' '--' 'other-owner' ||
    fail "another owner's executable must not claim the request"
  pass "another owner's executable is ignored"
else
  skip "other-owner executable: no different-owner fixture available"
fi

# Disabling a broken dispatcher restores normal launches without retrying it.
rm "$test_home/.config/omarchy/agents/request-dispatch"
cat >"$test_home/.config/omarchy/agents/request-dispatch" <<'SH'
#!/bin/bash
exit 126
SH
chmod +x "$test_home/.config/omarchy/agents/request-dispatch"
: >"$launch_log"
if run_agent --inline --prompt 'broken-dispatcher'; then
  fail "broken dispatcher must stop the current request"
else
  [[ $? == 126 && ! -s $launch_log ]] || fail "broken dispatcher status or ownership was lost"
fi
mv "$test_home/.config/omarchy/agents/request-dispatch" "$test_home/.config/omarchy/agents/request-dispatch.disabled"
run_agent --inline --prompt 'new-request'
assert_launch 'claude' '--permission-mode' 'auto' '--' 'new-request' ||
  fail "disabled dispatcher must permit a new normal launch"
pass "disabling a broken dispatcher restores new launches"
