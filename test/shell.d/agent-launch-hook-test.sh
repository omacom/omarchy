#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
hook_log="$test_tmp/hook.log"
harness_log="$test_tmp/harness.log"
mkdir -p "$mock_bin" "$test_home/.config/omarchy/defaults" "$test_home/.config/omarchy/hooks" \
  "$test_home/Work/demo"
printf 'pi\n' >"$test_home/.config/omarchy/defaults/agent"

cat >"$mock_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$mock_bin/pi" <<'SH'
#!/bin/bash
printf 'started\n' >>"$OMARCHY_TEST_HARNESS_LOG"
SH
chmod +x "$mock_bin/omarchy-cmd-missing" "$mock_bin/pi"

cat >"$test_home/.config/omarchy/hooks/agent-launch" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_HOOK_LOG"
SH
chmod +x "$test_home/.config/omarchy/hooks/agent-launch"

HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_HOOK_LOG="$hook_log" \
  OMARCHY_TEST_HARNESS_LOG="$harness_log" \
  bash -c 'cd "$1" && omarchy-agent --inline' bash "$test_home/Work/demo"

grep -Fxq "pi $test_home/Work/demo" "$hook_log" ||
  fail "agent-launch hook did not see harness and cwd" "$(cat "$hook_log" 2>/dev/null)"
pass "agent-launch hook runs with harness and cwd"

# A failing hook must not prevent the agent from starting.
cat >"$test_home/.config/omarchy/hooks/agent-launch" <<'SH'
#!/bin/bash
exit 7
SH
chmod +x "$test_home/.config/omarchy/hooks/agent-launch"
: >"$harness_log"
HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_HARNESS_LOG="$harness_log" \
  bash -c 'cd "$1" && omarchy-agent --inline' bash "$test_home/Work/demo" ||
  fail "a failing agent-launch hook blocks the harness"
if [[ $(cat "$harness_log") != "started" ]]; then
  fail "a failing agent-launch hook must still execute the harness"
fi
pass "a failing agent-launch hook does not block the harness"

# A notification hook must not consume the inline harness input or print into it.
cat >"$test_home/.config/omarchy/hooks/agent-launch" <<'SH'
#!/bin/bash
cat >"$OMARCHY_TEST_HOOK_LOG"
echo 'hook stdout'
echo 'hook stderr' >&2
SH
cat >"$mock_bin/pi" <<'SH'
#!/bin/bash
cat >"$OMARCHY_TEST_HARNESS_LOG"
SH
chmod +x "$mock_bin/pi" "$test_home/.config/omarchy/hooks/agent-launch"
printf 'terminal input' | HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH"   OMARCHY_TEST_HOOK_LOG="$hook_log" OMARCHY_TEST_HARNESS_LOG="$harness_log"   "$ROOT/bin/omarchy-agent" --inline >"$test_tmp/output" 2>&1
[[ ! -s $hook_log && ! -s $test_tmp/output && $(cat "$harness_log") == "terminal input" ]] ||
  fail "notification hook must not consume terminal input or emit terminal output"
pass "hook IO is isolated from the inline harness"

# Use the real timeout; a hook ignoring TERM is still bounded by kill-after.
cat >"$test_home/.config/omarchy/hooks/agent-launch" <<'SH'
#!/bin/bash
trap '' TERM
sleep 60
SH
chmod +x "$test_home/.config/omarchy/hooks/agent-launch"
start=$SECONDS
printf 'after timeout' | HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH"   OMARCHY_TEST_HARNESS_LOG="$harness_log"   "$ROOT/bin/omarchy-agent" --inline >"$test_tmp/output" 2>&1
elapsed=$((SECONDS - start))
(( elapsed >= 5 && elapsed < 12 )) && [[ ! -s $test_tmp/output && $(cat "$harness_log") == "after timeout" ]] ||
  fail "slow notification hook must be terminated before the harness starts" "$elapsed seconds"
pass "a hook ignoring TERM cannot block the launch indefinitely"
