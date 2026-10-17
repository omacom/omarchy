#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home/.config/omarchy/defaults" "$test_tmp/work"
ln -s "$ROOT" "$test_tmp/omarchy source"

export HOME="$test_tmp/home"
export OMARCHY_PATH="$test_tmp/omarchy source"
export PATH="$mock_bin:$ROOT/bin:$PATH"
export OMARCHY_TEST_AGENT_LOG="$test_tmp/agent-log"
export OMARCHY_TEST_LAUNCH_LOG="$test_tmp/launch-log"
export OMARCHY_TEST_INLINE_LOG="$test_tmp/inline-log"
export OMARCHY_TEST_MENU_LOG="$test_tmp/menu-log"
export OMARCHY_TEST_NOTIFICATION_LOG="$test_tmp/notification-log"
export OMARCHY_TEST_HERMES_SOURCE_LOG="$test_tmp/hermes-source-log"
export OMARCHY_TEST_REAL_AGENT=false
export HERMES_SESSION_SOURCE=parent-session
unset CLAUDE_CONFIG_DIR CODEX_HOME GROK_HOME
unset OMARCHY_AGENT_CLAUDE_HOME OMARCHY_AGENT_CODEX_HOME OMARCHY_AGENT_GROK_HOME
agent_file="$HOME/.config/omarchy/defaults/agent"
cd "$test_tmp/work"

# The first layer records the wrapper's exact argv. Integration cases then
# delegate to the real launcher, whose external effects are all stubbed below.
cat >"$mock_bin/omarchy-agent" <<'STUB'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_AGENT_LOG"
if [[ $OMARCHY_TEST_REAL_AGENT == "true" ]]; then
  exec "$ROOT/bin/omarchy-agent" "$@"
fi
STUB

cat >"$mock_bin/omarchy-launch-tui" <<'STUB'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_LAUNCH_LOG"
STUB

cat >"$mock_bin/omarchy-menu" <<'STUB'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_MENU_LOG"
STUB

cat >"$mock_bin/omarchy-notification-send" <<'STUB'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_NOTIFICATION_LOG"
STUB

cat >"$mock_bin/omarchy-cmd-missing" <<'STUB'
#!/bin/bash
[[ $1 == ${OMARCHY_TEST_MISSING_COMMAND:-} ]]
STUB

cat >"$mock_bin/omarchy-agent-account-home" <<'STUB'
#!/bin/bash
exit 0
STUB

cat >"$mock_bin/agent-stub" <<'STUB'
#!/bin/bash
printf '%s\0' "${0##*/}" "$@" >"$OMARCHY_TEST_INLINE_LOG"
printf '%s' "${HERMES_SESSION_SOURCE:-}" >"$OMARCHY_TEST_HERMES_SOURCE_LOG"
STUB

for agent in pi omp opencode ori claude codex grok agy hermes copilot crush cursor-agent muse omarchy-launch-openclaw; do
  ln -s agent-stub "$mock_bin/$agent"
done
chmod +x "$mock_bin"/*

reset_logs() {
  local log
  for log in "$OMARCHY_TEST_AGENT_LOG" "$OMARCHY_TEST_LAUNCH_LOG" "$OMARCHY_TEST_INLINE_LOG" \
    "$OMARCHY_TEST_MENU_LOG" "$OMARCHY_TEST_NOTIFICATION_LOG" "$OMARCHY_TEST_HERMES_SOURCE_LOG"; do
    : >"$log"
  done
}

assert_args() {
  local log=$1 description=$2 index=0
  shift 2
  local -a actual=() expected=("$@")
  mapfile -d '' -t actual <"$log"
  (( ${#actual[@]} == ${#expected[@]} )) ||
    fail "$description" "Expected ${#expected[@]} arguments, got ${#actual[@]}: ${actual[*]}"
  for ((index = 0; index < ${#expected[@]}; index++)); do
    [[ ${actual[index]} == "${expected[index]}" ]] ||
      fail "$description" "Argument $index: expected [${expected[index]}], got [${actual[index]}]"
  done
}

assert_no_effects() {
  [[ ! -s $OMARCHY_TEST_AGENT_LOG && ! -s $OMARCHY_TEST_LAUNCH_LOG && ! -s $OMARCHY_TEST_INLINE_LOG &&
    ! -s $OMARCHY_TEST_MENU_LOG && ! -s $OMARCHY_TEST_NOTIFICATION_LOG ]] || fail "$1"
}

run_investigate() {
  "$ROOT/bin/omarchy-agent-investigate" "$@"
}

# Use a real default file even in the wrapper-only cases, because the wrapper
# checks whether this harness can accept an interactive initial prompt.
printf '%s\n' opencode >"$agent_file"
reset_logs
run_investigate
mapfile -d '' -t wrapper_args <"$OMARCHY_TEST_AGENT_LOG"
(( ${#wrapper_args[@]} == 2 )) || fail "investigation sends one initial prompt"
[[ ${wrapper_args[0]} == "--prompt" ]] || fail "investigation uses the prompt option"
prompt=${wrapper_args[1]}
[[ $prompt == *"Use the diagnose-omarchy skill"* ]] || fail "investigation names its diagnostic skill"
[[ $prompt == *"$OMARCHY_PATH/default/agents/skills/diagnose-omarchy/SKILL.md"* ]] ||
  fail "investigation supplies the absolute skill fallback, including spaces"
[[ $prompt == *"Do not upload diagnostics"* ]] || fail "investigation asks for review before publishing diagnostics"
pass "investigation sends its skill, review instruction, and absolute fallback as one prompt"

assert_forwarded() {
  reset_logs
  run_investigate "$@"
  assert_args "$OMARCHY_TEST_AGENT_LOG" "investigation forwards [$*] intact" "$@" --prompt "$prompt"
}
assert_forwarded --inline
assert_forwarded --pick
assert_forwarded --inline --pick
assert_forwarded --pick --inline
pass "investigation accepts inline and picker options in either order"

assert_invalid() {
  local status=0 usage
  reset_logs
  usage=$(run_investigate "$@" 2>&1) || status=$?
  (( status == 1 )) || fail "investigation rejects [$*]"
  [[ $usage == *"Usage: omarchy agent investigate [--inline] [--pick]"* ]] ||
    fail "invalid investigation arguments explain the supported options"
  assert_no_effects "invalid investigation arguments never launch, notify, or open a picker"
}
assert_invalid unexpected
assert_invalid --unknown
assert_invalid --inline unexpected
assert_invalid --pick --prompt "unrequested prompt"
assert_invalid --inline --pick unexpected
pass "invalid investigation arguments fail before any external effect"

reset_logs
"$ROOT/bin/omarchy" agent investigate --pick --inline
assert_args "$OMARCHY_TEST_AGENT_LOG" "public CLI resolves the investigate subcommand" --pick --inline --prompt "$prompt"
pass "the public CLI routes investigation without treating it as an agent prompt"

export OMARCHY_TEST_REAL_AGENT=true
rm "$agent_file"
reset_logs
status=0
error=$(run_investigate --inline 2>&1) || status=$?
(( status == 1 )) || fail "inline investigation fails clearly without a default agent"
[[ $error == *"Choose default agent with:"* ]] || fail "inline investigation explains how to choose a default"
[[ ! -s $OMARCHY_TEST_LAUNCH_LOG && ! -s $OMARCHY_TEST_INLINE_LOG && ! -s $OMARCHY_TEST_MENU_LOG ]] ||
  fail "inline investigation without a default opens nothing"
pass "an unset default gives terminal users a useful error"

reset_logs
run_investigate --pick
assert_args "$OMARCHY_TEST_MENU_LOG" "unset default opens the actual launcher's picker" summon setup.default.agent
[[ ! -s $OMARCHY_TEST_LAUNCH_LOG && ! -s $OMARCHY_TEST_INLINE_LOG ]] ||
  fail "unset default does not launch an agent before the user chooses one"
[[ ! -e $agent_file ]] || fail "investigation does not choose a default on the user's behalf"
pass "the desktop investigation opens the default-agent picker when needed"

# Preserve the shared launcher's current integrations. The Gemini aliases now
# resolve to Antigravity (agy); do not invent a stale gemini launcher branch.
assert_agent() {
  local agent=$1
  shift
  local -a command=("$@") terminal_command=("$@")
  case "$agent" in
    claude) terminal_command=(env -u CLAUDE_CONFIG_DIR OMARCHY_AGENT_CLAUDE_HOME= "${command[@]}") ;;
    codex) terminal_command=(env -u CODEX_HOME OMARCHY_AGENT_CODEX_HOME= "${command[@]}") ;;
    grok) terminal_command=(env -u GROK_HOME OMARCHY_AGENT_GROK_HOME= "${command[@]}") ;;
    hermes) terminal_command=(env -u HERMES_SESSION_SOURCE "${command[@]}") ;;
  esac

  printf '%s\n' "$agent" >"$agent_file"
  reset_logs
  run_investigate --pick
  assert_args "$OMARCHY_TEST_LAUNCH_LOG" "$agent retains its prompted desktop launch" \
    --app-id=org.omarchy.agent "${terminal_command[@]}"
  [[ ! -s $OMARCHY_TEST_MENU_LOG && ! -s $OMARCHY_TEST_NOTIFICATION_LOG && ! -s $OMARCHY_TEST_INLINE_LOG ]] ||
    fail "$agent desktop launch does not open a picker or execute inline"

  reset_logs
  run_investigate --inline --pick
  assert_args "$OMARCHY_TEST_INLINE_LOG" "$agent retains its prompted inline launch" "${command[@]}"
  [[ ! -s $OMARCHY_TEST_LAUNCH_LOG && ! -s $OMARCHY_TEST_MENU_LOG && ! -s $OMARCHY_TEST_NOTIFICATION_LOG ]] ||
    fail "$agent inline launch does not open a desktop surface"
  if [[ $agent == "hermes" ]]; then
    [[ ! -s $OMARCHY_TEST_HERMES_SOURCE_LOG ]] || fail "Hermes launches outside the parent's session source"
  fi
  pass "investigation preserves $agent desktop and inline launch arguments"
}

assert_agent pi pi "$prompt"
assert_agent omp omp --auto-approve -- "$prompt"
assert_agent opencode opencode --auto --prompt "$prompt"
assert_agent ori ori code --interactive --prompt "$prompt"
assert_agent claude claude --permission-mode auto -- "$prompt"
assert_agent codex codex --approve-for-me -- "$prompt"
assert_agent grok grok --permission-mode bypassPermissions -- "$prompt"
assert_agent openclaw omarchy-launch-openclaw --tui --message "$prompt"
assert_agent agy agy --dangerously-skip-permissions --prompt-interactive "$prompt"
assert_agent hermes hermes chat --yolo --tui "--query=$prompt"
assert_agent copilot copilot --allow-all --interactive "$prompt"
assert_agent cursor-agent cursor-agent --yolo --trust agent -- "$prompt"
assert_agent muse muse --approval-mode never -- "$prompt"

assert_crush_blocked() {
  local status=0 error argument inline=false
  for argument in "$@"; do
    [[ $argument == "--inline" ]] && inline=true
  done
  reset_logs
  error=$(run_investigate "$@" 2>&1) || status=$?
  (( status == 1 )) || fail "Crush investigation reports its unsupported prompted interaction"
  [[ $error == *"Crush"* && $error == *"default agent"* ]] ||
    fail "Crush investigation explains the limitation and how to choose another agent" "$error"
  [[ ! -s $OMARCHY_TEST_AGENT_LOG && ! -s $OMARCHY_TEST_LAUNCH_LOG && ! -s $OMARCHY_TEST_INLINE_LOG &&
    ! -s $OMARCHY_TEST_MENU_LOG ]] || fail "Crush investigation never runs a one-shot agent or changes the default"
  [[ $(<"$agent_file") == "crush" ]] || fail "Crush guard leaves the chosen default alone"
  if [[ $inline == "true" ]]; then
    [[ ! -s $OMARCHY_TEST_NOTIFICATION_LOG ]] || fail "inline Crush guard uses stderr without a desktop notification"
  else
    local -a notification=()
    mapfile -d '' -t notification <"$OMARCHY_TEST_NOTIFICATION_LOG"
    local length=${#notification[@]}
    (( length >= 6 )) || fail "desktop Crush guard sends an actionable notification"
    [[ ${notification[*]} == *"Crush"* ]] || fail "Crush notification identifies the affected agent"
    [[ ${notification[length-4]} == "--exec" && ${notification[length-3]} == "omarchy-menu" &&
      ${notification[length-2]} == "summon" && ${notification[length-1]} == "setup.default.agent" ]] ||
      fail "Crush notification offers the default-agent picker"
  fi
}
printf '%s\n' crush >"$agent_file"
assert_crush_blocked
assert_crush_blocked --pick
assert_crush_blocked --inline
assert_crush_blocked --inline --pick
assert_crush_blocked --pick --inline
pass "Crush guard stays visible on desktop and inline paths without running an agent"

run_node_test <<'JS'
const fs = require('fs')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const items = menu.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
const byId = Object.fromEntries(items.map(item => [item.id, item]))
const entry = byId['trigger.investigate']
const skill = fs.readFileSync(path.join(root, 'default/agents/skills/diagnose-omarchy/SKILL.md'), 'utf8')

assertEqual(entry.label, 'Hunt Bugs', 'menu exposes the investigation action')
assertEqual(entry.action, 'omarchy-agent-investigate --pick', 'menu requests the default-agent picker')
for (const query of ['hunt', 'bugs', 'investigate', 'bug', 'desktop problem', 'AI']) {
  assert(menu.matchesQuery(entry, query, true), `menu finds the investigation for ${query}`)
}
assert(!entry.aliases || entry.aliases.length === 0, 'new investigation entry does not add menu aliases')
assert(skill.includes('name: diagnose-omarchy'), 'the diagnostic skill ships with the expected name')
JS
