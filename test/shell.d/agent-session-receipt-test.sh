#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
runtime="$test_tmp/runtime"
launch_log="$test_tmp/launch.log"
mkdir -p "$mock_bin" "$test_home/.config/omarchy/defaults" "$test_home/Work/demo" "$runtime"
printf 'codex\n' >"$test_home/.config/omarchy/defaults/agent"

cat >"$mock_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$mock_bin/omarchy-launch-tui" <<'SH'
#!/bin/bash
echo terminal >"$OMARCHY_TEST_LAUNCH_LOG"
SH
cat >"$mock_bin/codex" <<'SH'
#!/bin/bash
echo inline >"$OMARCHY_TEST_LAUNCH_LOG"
SH
chmod +x "$mock_bin/omarchy-cmd-missing" "$mock_bin/omarchy-launch-tui" "$mock_bin/codex"

run_agent() {
  : >"$launch_log"
  HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" XDG_RUNTIME_DIR="$runtime" \
    OMARCHY_TEST_LAUNCH_LOG="$launch_log" \
    bash -c 'cd "$1" && shift && omarchy-agent "$@"' bash "$test_home/Work/demo" "$@"
}

run_agent --inline

receipt="$runtime/omarchy/agent-session.env"
[[ -f $receipt ]] || fail "agent launch does not write a session receipt"
# shellcheck disable=SC1090
source "$receipt"
[[ $OMARCHY_AGENT == "codex" ]] || fail "receipt agent is wrong: $OMARCHY_AGENT"
[[ $OMARCHY_AGENT_CWD == "$test_home/Work/demo" ]] || fail "receipt cwd is wrong: $OMARCHY_AGENT_CWD"
[[ $OMARCHY_AGENT_INLINE == "true" ]] || fail "receipt inline flag is wrong: $OMARCHY_AGENT_INLINE"
[[ -n $OMARCHY_AGENT_STARTED_AT ]] || fail "receipt is missing a start timestamp"
[[ $(cat "$launch_log") == "inline" ]] || fail "inline harness did not start"
pass "inline launch writes a sourceable session receipt"

run_agent
source "$receipt"
[[ $OMARCHY_AGENT_INLINE == "false" ]] || fail "default receipt must report non-inline launch"
[[ $(cat "$launch_log") == "terminal" ]] || fail "default launch did not reach the terminal"
pass "default launch publishes a non-inline receipt and opens the terminal"

cp "$receipt" "$test_tmp/previous.env"
# Model a short filesystem write without depending on host disk capacity.
cat >"$test_tmp/short-write.sh" <<'SH'
printf() {
  if [[ ${1:-} == OMARCHY_AGENT=* ]]; then
    builtin printf 'partial receipt\n'
    return 1
  fi
  builtin printf "$@"
}
SH
BASH_ENV="$test_tmp/short-write.sh" run_agent --inline 2>"$test_tmp/err"
[[ $(cat "$launch_log") == "inline" ]] || fail "receipt write failure blocked launch"
[[ ! -s $test_tmp/err ]] || fail "receipt write failure produced stderr"
cmp -s "$receipt" "$test_tmp/previous.env" || fail "short write replaced the previous complete receipt"
if compgen -G "$runtime/omarchy/.agent-session.*" >/dev/null; then
  fail "short write left a temporary receipt"
fi
pass "short writes preserve the previous receipt and still launch the harness"

# A failed rename must also keep the previously published record.
cat >"$mock_bin/mv" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$mock_bin/mv"
run_agent --inline 2>"$test_tmp/err"
cmp -s "$receipt" "$test_tmp/previous.env" || fail "failed rename changed the receipt"
[[ $(cat "$launch_log") == "inline" && ! -s $test_tmp/err ]] || fail "failed rename affected launch"
if compgen -G "$runtime/omarchy/.agent-session.*" >/dev/null; then
  fail "failed rename left a temporary receipt"
fi
pass "rename failure preserves the published receipt and cleans temporary output"
rm "$mock_bin/mv"

runtime="$test_tmp/not-a-directory"
: >"$runtime"
run_agent --inline 2>"$test_tmp/err"
[[ $(cat "$launch_log") == "inline" ]] || fail "unavailable runtime directory blocked launch"
[[ ! -s $test_tmp/err ]] || fail "unavailable runtime directory produced stderr" "$(cat "$test_tmp/err")"
pass "unavailable runtime directory is quiet and does not block launch"
