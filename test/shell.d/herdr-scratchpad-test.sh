#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf -- "$test_tmp"' EXIT

scratchpad_config="$ROOT/config/herdr/scratchpad.toml"
launcher="$ROOT/bin/omarchy-scratchpad-agent"

# resume_agents_on_restore is off, so the launcher has no resume state to read.
launcher_source=$(<"$launcher")
[[ $launcher_source != *"agent_session"* ]] ||
  fail "the launcher does not read Herdr resume state"

config_source=$(<"$scratchpad_config")
for setting in \
  'default_shell = "omarchy-scratchpad-agent"' \
  'shell_mode = "non_login"' \
  'sidebar_collapsed_mode = "hidden"' \
  'hide_tab_bar_when_single_tab = true' \
  'pane_borders = false' \
  'pane_outer_borders = false' \
  'pane_gaps = false' \
  'pane_scrollbars = false' \
  'delivery = "system"' \
  'delay_seconds = 1' \
  'enabled = true' \
  'resume_agents_on_restore = false'; do
  [[ $config_source == *"$setting"* ]] || fail "scratchpad profile sets $setting"
done
pass "scratchpad profile configures a minimal UI, notifications, sound, and fresh panes"

test_home="$test_tmp/home"
mkdir -p "$test_home"
HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
  bash -euo pipefail "$ROOT/migrations/1788016185.sh" >/dev/null
[[ -f $test_home/.config/herdr/scratchpad.toml ]] ||
  fail "migration seeds the scratchpad profile"

printf '%s\n' custom >"$test_home/.config/herdr/scratchpad.toml"
HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
  bash -euo pipefail "$ROOT/migrations/1788016185.sh" >/dev/null
[[ $(<"$test_home/.config/herdr/scratchpad.toml") == custom ]] ||
  fail "migration preserves an existing scratchpad profile"
pass "migration seeds the profile without replacing customization"

mock_bin="$test_tmp/bin"
agent_log="$test_tmp/agent.log"
shell_log="$test_tmp/shell.log"
rename_log="$test_tmp/rename.log"
mkdir -p "$mock_bin"

cat >"$mock_bin/herdr" <<'SH'
#!/bin/bash
[[ $1 == "workspace" && $2 == "rename" ]] &&
  printf '%s %s\n' "$3" "$4" >>"$OMARCHY_TEST_RENAME_LOG"
SH

cat >"$mock_bin/omarchy-agent" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_AGENT_LOG"
[[ ${OMARCHY_TEST_AGENT_FAILS:-false} == true ]] && exit 1
SH

cat >"$mock_bin/test-shell" <<'SH'
#!/bin/bash
printf '%s\n' started >"$OMARCHY_TEST_SHELL_LOG"
SH

chmod +x "$mock_bin"/*

run_launcher() {
  HOME="$test_home" PATH="$mock_bin:$PATH" HERDR_WORKSPACE_ID=workspace \
    OMARCHY_TEST_AGENT_LOG="$agent_log" OMARCHY_TEST_SHELL_LOG="$shell_log" \
    OMARCHY_TEST_RENAME_LOG="$rename_log" "$launcher"
}

: >"$agent_log"
: >"$rename_log"
run_launcher
mapfile -d '' -t agent_args <"$agent_log"
[[ ${agent_args[*]} == "--inline" ]] ||
  fail "scratchpad panes launch the default agent inline"
[[ $(<"$rename_log") == "workspace scratchpad" ]] ||
  fail "scratchpad panes rename the Herdr workspace"
pass "scratchpad panes start a fresh agent and name their workspace"

: >"$agent_log"
rm -f "$shell_log"
OMARCHY_TEST_AGENT_FAILS=true SHELL="$mock_bin/test-shell" run_launcher
[[ -f $shell_log ]] || fail "a failed agent leaves a shell in the scratchpad"
pass "a failed agent falls back to a shell"
