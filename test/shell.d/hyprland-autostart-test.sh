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
local waylandDisplay = nil
local shellRunning = false

hl = {
  on = function(event, callback) handlers[event] = callback end,
  exec_cmd = function(command) table.insert(commands, command) end,
}
o = { launch = function(command) return command end }
os.getenv = function(name)
  if name == "WAYLAND_DISPLAY" then return waylandDisplay end
end
os.execute = function(command)
  assert(command == "omarchy-shell shell ping >/dev/null 2>&1", "unexpected startup guard command")
  if shellRunning then return true, "exit", 0 end
  return nil, "exit", 1
end

dofile(arg[1])
local function hasCommand(needle)
  for _, command in ipairs(commands) do
    if command:find(needle, 1, true) then return true end
  end
  return false
end

if arg[2] == "normal" then
  waylandDisplay = nil
  handlers["config.reloaded"]()
  assert(#commands == 0, "the initial config reload ran before Wayland was ready")
  waylandDisplay = "wayland-1"
  handlers["hyprland.start"]()
  assert(#commands > 0, "normal startup did not launch session services")
  assert(hasCommand("omarchy-launch-shell"), "normal startup did not restore the shell")
  assert(hasCommand("omarchy-hook post-boot"), "normal startup did not run post-boot hooks")
  shellRunning = true
elseif arg[2] == "safe-mode" then
  waylandDisplay = "wayland-1"
  handlers["config.reloaded"]()
  assert(#commands > 0, "loading the user config after safe-mode did not launch services")
  assert(hasCommand("omarchy-launch-shell"), "safe-mode recovery did not restore the shell")
  assert(hasCommand("omarchy-hook post-boot"), "safe-mode recovery did not run post-boot hooks")
  shellRunning = true
elseif arg[2] == "existing-session" then
  waylandDisplay = "wayland-1"
  shellRunning = true
  handlers["config.reloaded"]()
  assert(#commands == 0, "a config reload repeated startup in an existing session")
else
  error("unknown startup scenario: " .. tostring(arg[2]))
end

local startupCommands = #commands
waylandDisplay = "wayland-1"
handlers["config.reloaded"]()
assert(#commands == startupCommands, "a later config reload repeated session startup")
LUA

run_case() {
  lua "$harness" "$ROOT/default/hypr/autostart.lua" "$1"
}

run_case normal
pass "normal Hyprland startup launches services once across config reloads"

run_case safe-mode
pass "loading the user config after Hyprland start restores session autostart once"

run_case existing-session
pass "loading config in an already-running session does not repeat autostart"
