#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

test_tmp=$(mktemp -d)
watch_pid=""
events_fd=""

stop_watcher() {
  local child descendants

  if [[ -n $watch_pid ]]; then
    descendants=$(pgrep -P "$watch_pid" 2>/dev/null || true)
    for child in $descendants; do
      descendants+=" $(pgrep -P "$child" 2>/dev/null || true)"
    done

    kill -KILL "$watch_pid" 2>/dev/null || true
    wait "$watch_pid" 2>/dev/null || true
    for child in $descendants; do
      kill -KILL "$child" 2>/dev/null || true
    done
    watch_pid=""
  fi

  if [[ -n $events_fd ]]; then
    exec {events_fd}>&-
    events_fd=""
  fi
}

cleanup() {
  stop_watcher
  rm -rf "$test_tmp"
}
trap cleanup EXIT

stub_bin="$test_tmp/bin"
watcher_bin="$test_tmp/watcher-bin"
command_log="$test_tmp/commands.log"
lid_log="$test_tmp/lid.log"
events="$test_tmp/events"
mkdir -p "$stub_bin" "$watcher_bin"

cat >"$stub_bin/omarchy-hyprland-monitor-laptop" <<'SH'
#!/bin/bash
printf 'clamshell continued\n' >>"$OMARCHY_TEST_COMMAND_LOG"
SH

cat >"$stub_bin/omarchy-hw-external-monitors" <<'SH'
#!/bin/bash
exit 1
SH

cat >"$watcher_bin/omarchy-hw-laptop" <<'SH'
#!/bin/bash
exit 1
SH

# The watcher runs the real reconciler, so this is where it would carry on past
# its guard. What it reads after that is stubbed, to keep it off the real hardware.
cat >"$watcher_bin/omarchy-hyprland-monitor-laptop" <<'SH'
#!/bin/bash
printf 'clamshell continued\n' >>"$OMARCHY_TEST_COMMAND_LOG"
SH

for command in omarchy-hw-clamshell omarchy-hyprland-monitor-external-active; do
  cat >"$watcher_bin/$command" <<'SH'
#!/bin/bash
exit 1
SH
done

for command in omarchy-hyprland-monitor-internal omarchy-hyprland-monitor-internal-mirror; do
  cat >"$watcher_bin/$command" <<'SH'
#!/bin/bash
exit 0
SH
done

cat >"$watcher_bin/omarchy-system-lid-inhibit" <<'SH'
#!/bin/bash
printf 'synced\n' >>"$OMARCHY_TEST_LID_LOG"
SH

cat >"$watcher_bin/omarchy-hyprland-monitor-modeless" <<'SH'
#!/bin/bash
printf 'modeless checked\n' >>"$OMARCHY_TEST_COMMAND_LOG"
exit 0
SH

cat >"$watcher_bin/omarchy-hyprland-reload-guard" <<'SH'
#!/bin/bash
exit 1
SH

cat >"$watcher_bin/hyprctl" <<'SH'
#!/bin/bash
[[ ${1:-} == "reload" ]] && printf 'monitor config reloaded\n' >>"$OMARCHY_TEST_COMMAND_LOG"
SH

cat >"$watcher_bin/socat" <<'SH'
#!/bin/bash
exec cat "$OMARCHY_TEST_EVENTS"
SH

chmod +x "$stub_bin"/* "$watcher_bin"/*

await_log_line() {
  local line="$1" waited

  for ((waited = 0; waited < 100; waited++)); do
    grep -Fqx "$line" "$command_log" 2>/dev/null && return 0
    sleep 0.05
  done

  return 1
}

await_lid_sync() {
  local waited

  for ((waited = 0; waited < 100; waited++)); do
    [[ -s $lid_log ]] && return 0
    sleep 0.05
  done

  return 1
}

start_watcher() {
  rm -f "$events"
  mkdir -p "$test_tmp/run"
  mkfifo "$events"

  HOME="$test_tmp/home" \
    PATH="$watcher_bin:$ROOT/bin:$PATH" \
    XDG_RUNTIME_DIR="$test_tmp/run" \
    HYPRLAND_INSTANCE_SIGNATURE=test \
    OMARCHY_TEST_COMMAND_LOG="$command_log" \
    OMARCHY_TEST_LID_LOG="$lid_log" \
    OMARCHY_TEST_EVENTS="$events" \
    "$ROOT/bin/omarchy-hyprland-monitor-watch" &
  watch_pid=$!

  exec {events_fd}<>"$events"
}

HOME="$test_tmp/home" PATH="$ROOT/bin:$PATH" omarchy-toggle monitor-management on

HOME="$test_tmp/home" PATH="$ROOT/bin:$PATH" omarchy-toggle-enabled monitor-management ||
  fail "monitor management did not report enabled after it was turned on"

HOME="$test_tmp/home" \
  PATH="$ROOT/bin:$PATH" \
  omarchy-toggle monitor-management off

if HOME="$test_tmp/home" PATH="$ROOT/bin:$PATH" omarchy-toggle-enabled monitor-management; then
  fail "monitor management reported enabled after it was turned off"
fi

HOME="$test_tmp/home" PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-hyprland-monitor-internal" toggle || true
HOME="$test_tmp/home" PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-hyprland-monitor-internal-mirror" toggle || true
[[ ! -e $command_log ]] || fail "laptop display keybindings ran while monitor management was disabled"
pass "laptop display keybindings respect external monitor ownership"

internal_toggle="$test_tmp/home/.local/state/omarchy/toggles/hypr/internal-monitor-disable.lua"
mkdir -p "$(dirname "$internal_toggle")"
touch "$internal_toggle"

HOME="$test_tmp/home" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-hw-recover-internal-monitor"

[[ -e $internal_toggle ]] || fail "startup recovery changed monitor state while monitor management was disabled"

clamshell_rule="$test_tmp/home/.local/state/omarchy/toggles/hypr/internal-monitor-clamshell.lua"
printf 'hl.monitor({ output = "eDP-1", disabled = true })\n' >"$clamshell_rule"

# A reload before the reconciler has had a chance to retire the rule.
hyprland_reload() {
  HOME="$test_tmp/home" XDG_STATE_HOME="$test_tmp/home/.local/state" OMARCHY_PATH="$ROOT" lua - "$1" <<'LUA'
local expected = tonumber(arg[1])
local rules = 0
hl = {
  monitor = function() rules = rules + 1 end,
  device = function() end,
  get_windows = function() return {} end,
  on = function() end,
}
dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")
require("default.hypr.toggles")
assert(rules == expected, "expected " .. expected .. " clamshell rules, loaded " .. rules)
LUA
}

hyprland_reload 0 || fail "a reload applied the clamshell rule while monitor management was disabled"
pass "a reload skips the clamshell rule while monitor management is off"

HOME="$test_tmp/home" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  OMARCHY_TEST_COMMAND_LOG="$command_log" \
  "$ROOT/bin/omarchy-hyprland-monitor-clamshell"

[[ ! -e $clamshell_rule ]] || fail "the clamshell rule outlived handing monitors to another manager"
[[ ! -e $command_log ]] || fail "retiring the clamshell rule ran monitor commands"
pass "the clamshell reconciler retires its rule while monitor management is off"

start_watcher
await_lid_sync || fail "monitor watcher stopped syncing the lid inhibitor while monitor management was disabled"
pass "the lid inhibitor stays in step while monitor management is off"

[[ ! -e $command_log ]] || fail "automatic monitor commands ran while monitor management was disabled"
kill -0 "$watch_pid" 2>/dev/null || fail "monitor watcher exited while monitor management was disabled"

HOME="$test_tmp/home" \
  PATH="$ROOT/bin:$PATH" \
  omarchy-toggle monitor-management on

[[ -e $test_tmp/home/.local/state/omarchy/toggles/monitor-management ]] || fail "monitor management remained disabled after turning it on"
HOME="$test_tmp/home" PATH="$ROOT/bin:$PATH" omarchy-toggle-enabled monitor-management ||
  fail "monitor management did not report enabled after turning it on"

printf 'monitoradded>>DP-1\n' >&"$events_fd"
await_log_line "clamshell continued" || fail "running monitor watcher did not resume clamshell handling"
await_log_line "monitor config reloaded" || fail "running monitor watcher did not resume modeless recovery"

HOME="$test_tmp/home" \
  PATH="$ROOT/bin:$PATH" \
  omarchy-toggle monitor-management off

: >"$command_log"
: >"$lid_log"
printf 'monitoradded>>DP-2\n' >&"$events_fd"
printf 'configreloaded>>\n' >&"$events_fd"
await_lid_sync || fail "monitor watcher stopped syncing the lid inhibitor after management was disabled"
sleep 1.5

[[ ! -s $command_log ]] || fail "running monitor watcher changed monitor state after management was disabled"
kill -0 "$watch_pid" 2>/dev/null || fail "monitor watcher exited instead of becoming ineffective"

HOME="$test_tmp/home" \
  PATH="$ROOT/bin:$PATH" \
  omarchy-toggle monitor-management on

printf 'monitorremoved>>DP-2\n' >&"$events_fd"
await_log_line "clamshell continued" || fail "same monitor watcher did not resume after management was re-enabled"
await_log_line "monitor config reloaded" || fail "modeless recovery did not resume after management was re-enabled"

stop_watcher

printf 'hl.monitor({ output = "eDP-1", disabled = true })\n' >"$clamshell_rule"
hyprland_reload 1 || fail "a reload skipped the clamshell rule while monitor management was enabled"
rm -f "$clamshell_rule"
pass "a reload applies the clamshell rule while monitor management is on"

HOME="$test_tmp/home" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-hw-recover-internal-monitor"

[[ ! -e $internal_toggle ]] || fail "startup recovery did not resume after monitor management was enabled"
pass "external monitor managers can turn Omarchy's automatic monitor handling off and on"
