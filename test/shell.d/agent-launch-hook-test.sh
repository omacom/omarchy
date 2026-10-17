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
export OMARCHY_TEST_HOOK_DIAGNOSTICS="$test_tmp/diagnostics"
cat >"$mock_bin/logger" <<'SH'
#!/bin/bash
[[ $* == "--tag omarchy-agent-hook" ]] || exit 1
cat >>"$OMARCHY_TEST_HOOK_DIAGNOSTICS"
SH
chmod +x "$mock_bin/logger"
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
grep -q 'agent-launch hook failed or timed out (status 1)'  "$OMARCHY_TEST_HOOK_DIAGNOSTICS" ||
  fail "hook failure diagnostics must reach the journal"
pass "a failing agent-launch hook logs its failure and does not block the harness"

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
: >"$OMARCHY_TEST_HOOK_DIAGNOSTICS"
printf 'terminal input' | HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH"   OMARCHY_TEST_HOOK_LOG="$hook_log" OMARCHY_TEST_HARNESS_LOG="$harness_log"   "$ROOT/bin/omarchy-agent" --inline >"$test_tmp/output" 2>&1
[[ ! -s $hook_log && ! -s $test_tmp/output && $(cat "$harness_log") == "terminal input" ]] ||
  fail "notification hook must not consume terminal input or emit terminal output"
[[ ! -s $OMARCHY_TEST_HOOK_DIAGNOSTICS ]] || fail "successful hook output must be discarded"
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
grep -q 'agent-launch hook failed or timed out (status ' "$OMARCHY_TEST_HOOK_DIAGNOSTICS" ||
  fail "a hook deadline must leave a journal diagnostic"
pass "a hook ignoring TERM cannot block the launch indefinitely"

# A returned hook may leave a child holding its diagnostic streams open.
cat >"$test_home/.config/omarchy/hooks/agent-launch" <<'SH'
#!/bin/bash
sleep 30 &
printf '%s\n' "$!" >"$OMARCHY_TEST_HOOK_LOG"
echo background-hook-returned
SH
start=$SECONDS
printf 'after background' | HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" \
  OMARCHY_TEST_HOOK_LOG="$hook_log" OMARCHY_TEST_HARNESS_LOG="$harness_log" \
  "$ROOT/bin/omarchy-agent" --inline >"$test_tmp/output" 2>&1
elapsed=$((SECONDS - start))
kill "$(cat "$hook_log")" 2>/dev/null || true
(( elapsed < 5 )) && [[ $(cat "$harness_log") == "after background" ]] ||
  fail "returned hook background streams delay the harness" "$elapsed seconds"
pass "background hook output cannot keep the launcher waiting"

# TERM must reach the hook with its default disposition so it can catch it.
cat >"$test_home/.config/omarchy/hooks/agent-launch" <<'SH'
#!/bin/bash
trap 'echo cleanup >"$OMARCHY_TEST_HOOK_LOG"; exit 0' TERM
while true; do sleep 0.1; done
SH
: >"$hook_log"
printf 'after cleanup' | HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" \
  OMARCHY_TEST_HOOK_LOG="$hook_log" OMARCHY_TEST_HARNESS_LOG="$harness_log" \
  "$ROOT/bin/omarchy-agent" --inline >"$test_tmp/output" 2>&1
[[ $(cat "$hook_log") == "cleanup" && $(cat "$harness_log") == "after cleanup" ]] ||
  fail "hook TERM cleanup must run before the harness starts"
pass "timed out hooks can run their TERM cleanup handler"

# A noisy hook cannot hide its failure behind the bounded output snapshot.
cat >"$test_home/.config/omarchy/hooks/agent-launch" <<'SH'
#!/bin/bash
head -c 1000000 /dev/zero
sleep 10
SH
: >"$OMARCHY_TEST_HOOK_DIAGNOSTICS"
printf 'after noisy hook' | HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" \
  OMARCHY_TEST_HARNESS_LOG="$harness_log" "$ROOT/bin/omarchy-agent" --inline >"$test_tmp/output" 2>&1
grep -aq 'agent-launch hook failed or timed out (status ' "$OMARCHY_TEST_HOOK_DIAGNOSTICS" ||
  fail "noisy hook must leave an independent failure diagnostic"
[[ $(wc -c <"$OMARCHY_TEST_HOOK_DIAGNOSTICS") -lt 34000 ]] ||
  fail "hook diagnostic output must stay bounded"
pass "noisy hooks keep bounded output and visible failure status"

# The log cap must not become an inherited limit on the hook's own files.
cat >"$test_home/.config/omarchy/hooks/agent-launch" <<'SH'
#!/bin/bash
head -c 100000 /dev/zero >"$OMARCHY_TEST_HOOK_LOG"
SH
HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" \
  OMARCHY_TEST_HOOK_LOG="$hook_log" OMARCHY_TEST_HARNESS_LOG="$harness_log" \
  "$ROOT/bin/omarchy-agent" --inline
[[ $(wc -c <"$hook_log") -eq 100000 ]] || fail "hook files must not inherit the diagnostic size limit"
pass "hooks can write files larger than the diagnostic snapshot"

# A returned hook's background child may safely keep its inherited output.
cat >"$test_home/.config/omarchy/hooks/agent-launch" <<'SH'
#!/bin/bash
(
  sleep 0.5
  echo 'background output'
  echo 'background error' >&2
  printf finished >"$OMARCHY_TEST_HOOK_LOG"
) &
SH
: >"$hook_log"
HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" \
  OMARCHY_TEST_HOOK_LOG="$hook_log" OMARCHY_TEST_HARNESS_LOG="$harness_log" \
  "$ROOT/bin/omarchy-agent" --inline
sleep 1
[[ $(cat "$hook_log") == finished ]] || fail "background output must not terminate the child with SIGPIPE"
pass "returned hook background work keeps safe output descriptors"
