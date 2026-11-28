#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
work_dir="$test_home/Work/project"
systemctl_log="$test_tmp/systemctl.log"
tui_log="$test_tmp/tui.log"
notify_log="$test_tmp/notify.log"

mkdir -p "$mock_bin" "$work_dir"

cat >"$mock_bin/systemctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_SYSTEMCTL_LOG"
[[ ${OMARCHY_TEST_SYSTEMCTL_FAIL:-false} != "true" ]]
SH

cat >"$mock_bin/omarchy-default-agent" <<'SH'
#!/bin/bash
printf '%s\n' "${OMARCHY_TEST_DEFAULT_AGENT:-agy}"
SH

cat >"$mock_bin/omarchy-agent-account-home" <<'SH'
#!/bin/bash
printf '%s\n' "${OMARCHY_TEST_ACCOUNT_HOME:-}"
SH

cat >"$mock_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
exit 1
SH

cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_NOTIFY_LOG"
SH

cat >"$mock_bin/omarchy-launch-tui" <<'SH'
#!/bin/bash
{
  printf 'PWD=%s\n' "$PWD"
  printf 'ARGS='
  printf '%q ' "$@"
  printf '\n'
} >"$OMARCHY_TEST_TUI_LOG"
SH

chmod +x "$mock_bin"/*

run_resume() {
  env -u CLAUDE_CONFIG_DIR -u CODEX_HOME -u GROK_HOME \
    -u OMARCHY_AGENT_CLAUDE_HOME -u OMARCHY_AGENT_CODEX_HOME -u OMARCHY_AGENT_GROK_HOME \
    HOME="$test_home" \
    XDG_CONFIG_HOME="$test_home/.config" \
    XDG_STATE_HOME="$test_home/.local/state" \
    OMARCHY_PATH="$ROOT" \
    PATH="$mock_bin:$ROOT/bin:$PATH" \
    OMARCHY_TEST_SYSTEMCTL_LOG="$systemctl_log" \
    OMARCHY_TEST_TUI_LOG="$tui_log" \
    OMARCHY_TEST_NOTIFY_LOG="$notify_log" \
    "$ROOT/bin/omarchy-agent-resume" "$@"
}

state_file="$test_home/.local/state/omarchy/agent-resume.json"
unit_file="$test_home/.config/systemd/user/omarchy-agent-resume.service"

# Initially inactive
! run_resume --active || fail "inactive before arming"
[[ $(run_resume status) == "Resume on next login is off." ]] || fail "status reports off when disarmed"
[[ $(run_resume status --json) == '{"armed":false}' ]] || fail "status --json reports armed:false when disarmed"
pass "reports disarmed state before arming"

# Arming agy writes 0600 JSON, installs unit with KillMode=process and env guards, and enables it
run_resume set --agent agy --session conv-123 --dir "$work_dir" --prompt "Check boot logs" >/dev/null
run_resume --active || fail "active after arming"
[[ -f $state_file && $(stat -c '%a' "$state_file") == "600" ]] || fail "state file exists with 0600 permissions"
grep -qxF "KillMode=process" "$unit_file" || fail "unit sets KillMode=process so uwsm-app child survives oneshot exit"
grep -qxF "ConditionEnvironment=OMARCHY_PATH" "$unit_file" || fail "unit guards OMARCHY_PATH"
grep -qxF "ConditionEnvironment=WAYLAND_DISPLAY" "$unit_file" || fail "unit guards WAYLAND_DISPLAY"
grep -qxF -- "--user enable omarchy-agent-resume.service" "$systemctl_log" || fail "unit is enabled on set"

status_out=$(run_resume status)
[[ $status_out == *"agent:    agy"* && $status_out == *"session:  conv-123"* ]] ||
  fail "status prints armed metadata" "$status_out"
pass "set arms 0600 state and enables KillMode=process user systemd unit"

# Running disarms immediately before launching through real omarchy-agent
run_resume run
! run_resume --active || fail "one-shot resume auto-disarms after run"
[[ ! -e $state_file && ! -e $unit_file ]] || fail "state and unit files are removed after run"
tui_out=$(cat "$tui_log")
[[ $tui_out == *"PWD=$work_dir"* ]] || fail "run switches to saved working directory" "$tui_out"
[[ $tui_out == *"ARGS=--app-id=org.omarchy.agent agy --dangerously-skip-permissions --conversation conv-123 --prompt-interactive Check\\ boot\\ logs "* ]] ||
  fail "run launches agy with exact conversation ID and prompt" "$tui_out"
pass "agy resume launches through omarchy-agent in saved dir and auto-disarms"

# Claude preserves explicit CLAUDE_CONFIG_DIR through omarchy-agent for uwsm launch
rm -f "$tui_log"
HOME="$test_home" XDG_CONFIG_HOME="$test_home/.config" XDG_STATE_HOME="$test_home/.local/state" \
  OMARCHY_PATH="$ROOT" PATH="$mock_bin:$ROOT/bin:$PATH" \
  OMARCHY_TEST_SYSTEMCTL_LOG="$systemctl_log" OMARCHY_TEST_TUI_LOG="$tui_log" \
  OMARCHY_TEST_NOTIFY_LOG="$notify_log" \
  CLAUDE_CONFIG_DIR="$test_home/.claude-work" \
  "$ROOT/bin/omarchy-agent-resume" set --agent claude --session sess-456 --dir "$work_dir" --prompt "Inspect crash" >/dev/null
run_resume run
! run_resume --active || fail "claude resume auto-disarms after run"
tui_out=$(cat "$tui_log")
[[ $tui_out == *"ARGS=--app-id=org.omarchy.agent env -u CLAUDE_CONFIG_DIR OMARCHY_AGENT_CLAUDE_HOME=$test_home/.claude-work CLAUDE_CONFIG_DIR=$test_home/.claude-work claude --permission-mode auto --resume sess-456 -- Inspect\\ crash "* ]] ||
  fail "claude resume carries CLAUDE_CONFIG_DIR and pin and passes --resume" "$tui_out"
pass "claude resume preserves account home and pin through uwsm launch"

# Main account (empty home) is preserved even if active account changes before login
rm -f "$tui_log"
OMARCHY_TEST_ACCOUNT_HOME="" run_resume set --agent codex --continue --dir "$work_dir" --prompt "Resume Main" >/dev/null
OMARCHY_TEST_ACCOUNT_HOME="$test_home/.codex-work" run_resume run
tui_out=$(cat "$tui_log")
[[ $tui_out == *"ARGS=--app-id=org.omarchy.agent env -u CODEX_HOME OMARCHY_AGENT_CODEX_HOME= codex --approve-for-me resume --last -- Resume\\ Main "* ]] ||
  fail "codex Main account stays pinned even after switching active account" "$tui_out"
pass "Main account is preserved across account switches before login"

# Missing saved directory aborts with error and notification instead of falling back to another dir
rm -f "$tui_log" "$notify_log"
missing_dir="$test_home/Work/ephemeral"
mkdir -p "$missing_dir"
run_resume set --agent agy --continue --dir "$missing_dir" --prompt "Do not run elsewhere" >/dev/null
rmdir "$missing_dir"
! run_resume run 2>/dev/null || fail "missing saved directory fails instead of substituting another directory"
[[ ! -e $tui_log ]] || fail "missing saved directory does not launch terminal"
grep -qF "$missing_dir" "$notify_log" || fail "missing saved directory notifies the user"
pass "missing saved directory aborts and notifies instead of opening wrong directory"

# Codex --continue with --prompt-file (multi-line) and idempotent off
prompt_file="$test_tmp/prompt.txt"
printf 'Line one\nLine two' >"$prompt_file"
run_resume set --agent codex --continue --dir "$work_dir" --prompt-file "$prompt_file" >/dev/null
status_out=$(run_resume status)
[[ $status_out == *$'  prompt:   Line one\n            Line two'* ]] ||
  fail "status indents multi-line prompts" "$status_out"
run_resume off >/dev/null
! run_resume --active || fail "off disarms state"
[[ ! -e $state_file && ! -e $unit_file ]] || fail "off removes state and unit"
run_resume off >/dev/null

rm -f "$tui_log"
run_resume set --agent codex --continue --dir "$work_dir" --prompt-file "$prompt_file" >/dev/null
run_resume run
tui_out=$(cat "$tui_log")
[[ $tui_out == *"codex --approve-for-me resume --last -- \$'Line one\\nLine two' "* ]] ||
  fail "codex --continue passes --last and full prompt after --" "$tui_out"
pass "codex --continue passes multi-line --prompt-file and off is idempotent"

# Session/continue flags across pi, opencode, kilo, and fresh-session hermes
rm -f "$tui_log"
run_resume set --agent pi --session pi-1 --dir "$work_dir" --prompt "Check GPU" >/dev/null
run_resume run
[[ $(cat "$tui_log") == *"ARGS=--app-id=org.omarchy.agent pi --session pi-1 Check\\ GPU "* ]] ||
  fail "pi resume passes --session and prompt" "$(cat "$tui_log")"

rm -f "$tui_log"
run_resume set --agent opencode --continue --dir "$work_dir" --prompt "Check logs" >/dev/null
run_resume run
[[ $(cat "$tui_log") == *"ARGS=--app-id=org.omarchy.agent opencode --auto --continue --prompt Check\\ logs "* ]] ||
  fail "opencode --continue passes --continue and --prompt" "$(cat "$tui_log")"

rm -f "$tui_log"
run_resume set --agent kilo --session kl-1 --dir "$work_dir" --prompt "-leading-dash" >/dev/null
run_resume run
[[ $(cat "$tui_log") == *"ARGS=--app-id=org.omarchy.agent kilo --auto --session kl-1 --prompt=-leading-dash "* ]] ||
  fail "kilo resume passes --session and bound --prompt=" "$(cat "$tui_log")"

rm -f "$tui_log"
run_resume set --agent hermes --dir "$work_dir" --prompt "Verify audio" >/dev/null
run_resume run
[[ $(cat "$tui_log") == *"ARGS=--app-id=org.omarchy.agent env -u HERMES_SESSION_SOURCE hermes chat --yolo --tui --query=Verify\\ audio "* ]] ||
  fail "hermes opens fresh session through omarchy-agent" "$(cat "$tui_log")"
pass "pi, opencode, kilo, and hermes launch with exact flags through omarchy-agent"

# Validation rejects bad agent/flags and preserves earlier arming if systemctl enable fails
! run_resume set --agent cluade --prompt "bad" 2>/dev/null || fail "rejects unknown agent name at set time"
! run_resume set --session a --continue 2>/dev/null || fail "rejects --session with --continue"
! run_resume set --prompt "a" --prompt-file "$prompt_file" 2>/dev/null || fail "rejects --prompt with --prompt-file"
! run_resume set --agent hermes --session s1 --prompt "bad" 2>/dev/null || fail "rejects --session for unsupported harness"

run_resume set --agent agy --session keep-me --dir "$work_dir" --prompt "Keep this" >/dev/null
! OMARCHY_TEST_SYSTEMCTL_FAIL=true run_resume set --agent claude --prompt "fail" 2>/dev/null || fail "fails when systemctl enable fails"
run_resume --active || fail "previous arming survives failed re-arm"
[[ $(jq -r '.session' "$state_file") == "keep-me" ]] || fail "previous state is untouched on failed re-arm"
run_resume off >/dev/null
! OMARCHY_TEST_SYSTEMCTL_FAIL=true run_resume set --agent agy --prompt "fail" 2>/dev/null || fail "fails when initial systemctl enable fails"
[[ ! -e $state_file && ! -e $unit_file ]] || fail "cleans up unit if initial systemctl enable fails"
pass "validates agent and flags at set time and preserves prior state on systemctl failure"
