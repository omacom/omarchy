#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

harness="$tmpdir/autostart.lua"
cat >"$harness" <<'LUA'
local handlers = {}
local commands = {}

hl = {
  on = function(event, callback) handlers[event] = callback end,
  exec_cmd = function(command) table.insert(commands, command) end,
}
o = { launch = function(command) return command end }

dofile(arg[1])
assert(handlers[arg[2]], "the expected startup event was not registered")
handlers[arg[2]]()
assert(#commands == 9, "startup should launch each session service and hook once")
assert(commands[2] == "omarchy-launch-shell", "startup did not restore the shell")
assert(commands[9] == "sleep 2 && omarchy-hook post-boot", "startup did not run post-boot hooks")

-- A fresh Lua state models Hyprland reloading the config. The runtime marker
-- must stop the new config.reloaded callback from running session startup twice.
handlers = {}
dofile(arg[1])
assert(handlers["config.reloaded"], "the config reload event was not registered")
handlers["config.reloaded"]()
assert(#commands == 9, "a config reload repeated session startup")
LUA

run_case() {
  local signature=$1 event=$2
  mkdir -p "$tmpdir/runtime/hypr/$signature"
  XDG_RUNTIME_DIR="$tmpdir/runtime" HYPRLAND_INSTANCE_SIGNATURE="$signature" \
    lua "$harness" "$ROOT/default/hypr/autostart.lua" "$event"
}

# Normal startup uses the compositor-start event; safe-mode config recovery has
# already passed that event, so its first startup must come from config.reloaded.
run_case normal-session hyprland.start
pass "normal Hyprland startup launches services once across config reloads"

run_case safe-mode-session config.reloaded
pass "loading the user config after Hyprland start restores session autostart once"
