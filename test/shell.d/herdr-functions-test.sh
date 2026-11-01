#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
source "$ROOT/default/bash/fns/herdr"

test_dir=$(mktemp -d)
trap 'rm -rf -- "$test_dir"' EXIT

mkdir -p "$test_dir/first project's files" "$test_dir/second project"
log="$test_dir/herdr.log"

herdr() {
  if [[ $1 == "workspace" ]]; then
    return
  elif [[ $1 == "tab" ]]; then
    printf '{"result":{"root_pane":{"pane_id":"new-pane"}}}\n'
  elif [[ $1 == "pane" && $2 == "run" ]]; then
    printf '%s\n' "$4" >>"$log"
  fi
}

export HERDR_PANE_ID="current-pane"
export HERDR_WORKSPACE_ID="workspace"

cd "$test_dir"
hdlm "codex --flag='value with spaces'" "claude --model sonnet"

mapfile -t commands <"$log"

expected_first=$(printf 'cd %q && hdl %q %q' \
  "$test_dir/first project's files" "codex --flag='value with spaces'" "claude --model sonnet")
expected_second=$(printf 'hdl %q %q' "codex --flag='value with spaces'" "claude --model sonnet")

[[ ${commands[0]} == "$expected_first" ]] || fail "hdlm safely quotes its first queued command"
pass "hdlm safely quotes its first queued command"

[[ ${commands[1]} == "$expected_second" ]] || fail "hdlm preserves agent argument boundaries"
pass "hdlm preserves agent argument boundaries"

: >"$log"
hdlm "codex --quiet"
mapfile -t commands <"$log"
expected_first=$(printf 'cd %q && hdl %q' "$test_dir/first project's files" "codex --quiet")

[[ ${commands[0]} == "$expected_first" ]] || fail "hdlm omits an absent second agent argument"
pass "hdlm omits an absent second agent argument"

# The qconsole profile makes bin/omarchy-qconsole-agent the shell of every Herdr
# pane, so the launcher is where a pane gets its name and its agent. Herdr, the
# agent and the user's shell are stubs here because the launcher runs all three
# as commands; only the launcher itself is real.
mock_bin="$test_dir/bin"
agent_log="$test_dir/agent.log"
shell_log="$test_dir/shell.log"
rename_log="$test_dir/rename.log"
mkdir -p "$mock_bin" "$test_dir/home"

cat >"$mock_bin/herdr" <<'SH'
#!/bin/bash
[[ $1 == "workspace" && $2 == "rename" ]] &&
  printf '%s %s\n' "$3" "$4" >>"$OMARCHY_TEST_RENAME_LOG"
exit 0
SH

cat >"$mock_bin/omarchy-agent" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_AGENT_LOG"
[[ ${OMARCHY_TEST_AGENT_FAILS:-false} == "true" ]] && exit 1
exit 0
SH

cat >"$mock_bin/test-shell" <<'SH'
#!/bin/bash
printf '%s\n' started >"$OMARCHY_TEST_SHELL_LOG"
SH

chmod +x "$mock_bin"/*

agent_fails=false

run_qconsole_launcher() {
  HOME="$test_dir/home" PATH="$mock_bin:$PATH" HERDR_WORKSPACE_ID=workspace \
    SHELL="$mock_bin/test-shell" OMARCHY_TEST_AGENT_LOG="$agent_log" \
    OMARCHY_TEST_AGENT_FAILS="$agent_fails" OMARCHY_TEST_SHELL_LOG="$shell_log" \
    OMARCHY_TEST_RENAME_LOG="$rename_log" \
    "$ROOT/bin/omarchy-qconsole-agent"
}

: >"$agent_log"
: >"$rename_log"
rm -f "$shell_log"
run_qconsole_launcher
mapfile -d '' -t agent_args <"$agent_log"

[[ ${agent_args[*]} == "--inline" ]] ||
  fail "a qconsole pane starts the default agent inline"
pass "a qconsole pane starts the default agent inline"

# Herdr names a workspace after the pane's cwd, which would be whatever directory
# the console happened to open in.
[[ $(<"$rename_log") == "workspace qconsole" ]] ||
  fail "a qconsole pane names its Herdr workspace after the console"
pass "a qconsole pane names its Herdr workspace after the console"

# The pane is already the agent, so a shell on top of it would be a second
# prompt in a console that has no room for one.
[[ ! -f $shell_log ]] ||
  fail "a pane whose agent starts leaves no shell behind"
pass "a pane whose agent starts leaves no shell behind"

# An account with no agent configured has to leave the user a usable shell.
agent_fails=true
: >"$agent_log"
rm -f "$shell_log"
run_qconsole_launcher

[[ -f $shell_log ]] ||
  fail "a pane falls back to a shell when its agent does not start"
pass "a pane falls back to a shell when its agent does not start"
