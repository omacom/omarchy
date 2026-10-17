#!/bin/bash

# The default SUPER + ALT + <number> binds switch to a window inside the
# focused group. Hyprland rejects an index past the end of the group, and a Lua
# bind surfaces that rejection as a "Runtime error in lua: Index out of range"
# notification, so the binds have to check the group first. Checking needs the
# live group, which makes them function binds, and Hyprland reports those as
# plain __lua without the dispatcher behind them: each one also has to name an
# equivalent command in o.bind_commands or the keybindings menu cannot run it.

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

tmpdir=$(mktemp -d) && [[ -n $tmpdir && -d $tmpdir ]] ||
  fail "the test gets a temporary directory for a stub home"
trap 'rm -rf "$tmpdir"' EXIT

# `lua -`, not bare `lua`: Lua exits 0 when a script it reads from a pipe
# errors, which would let a failing assertion below pass as a successful run.
output=$(HOME="$tmpdir" XDG_CONFIG_HOME="$tmpdir/.config" XDG_STATE_HOME="$tmpdir/.local/state" \
  OMARCHY_PATH="$ROOT" lua - 2>&1 <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local binds, dispatched = {}, {}
local active_window = nil

-- hl.dsp.<path>(args) stands in for a Hyprland dispatcher, recording which one
-- the bind asked for rather than talking to a compositor.
local function dsp_proxy(path)
  return setmetatable({}, {
    __index = function(_, key)
      return dsp_proxy(path .. "." .. tostring(key))
    end,
    __call = function(_, args)
      return { path = path, args = args }
    end,
  })
end

hl = setmetatable({
  dsp = dsp_proxy("hl.dsp"),
  bind = function(keys, dispatcher, opts)
    opts = opts or {}
    binds[#binds + 1] = { keys = keys, description = opts.description, dispatcher = dispatcher }
  end,
  dispatch = function(dispatcher)
    dispatched[#dispatched + 1] = dispatcher
  end,
  get_active_window = function()
    return active_window
  end,
  get_config = function()
    return nil
  end,
}, {
  __index = function()
    return function()
      return {}
    end
  end,
})

require("default.hypr.helpers")
require("default.hypr.bindings.tiling")

local function check(ok, description)
  if not ok then
    error(description, 0)
  end
  print("ok - " .. description)
end

-- The five binds are present, and each is a function bind the menu can still
-- reach through o.bind_commands.
for index = 1, 5 do
  local keys = "SUPER + ALT + code:" .. tostring(index + 9)
  local found

  for _, bind in ipairs(binds) do
    if bind.keys == keys and bind.description == "Switch to group window " .. index then
      found = bind
    end
  end

  check(found ~= nil, "a bind exists for group window " .. index)
  check(type(found.dispatcher) == "function", "group window " .. index .. " binds a function, so it can check the group")

  local command = o.bind_commands[found.dispatcher]
  check(type(command) == "string" and command ~= "",
    "group window " .. index .. " names a command the keybindings menu can run")
  check(command:find("o.switch_group_window(" .. index .. ")", 1, true) ~= nil,
    "group window " .. index .. "'s menu command switches to that index: " .. command)
end

-- Switching inside the group's bounds still dispatches.
local function switches_for(window, index)
  active_window = window
  dispatched = {}
  o.switch_group_window(index)
  return dispatched[1]
end

local two_window_group = { group = { size = 2 } }

local first = switches_for(two_window_group, 1)
check(first ~= nil and first.path == "hl.dsp.group.active" and first.args.index == 1,
  "the first window of a two-window group still switches")

local second = switches_for(two_window_group, 2)
check(second ~= nil and second.args.index == 2,
  "the second window of a two-window group still switches")

-- Past the end of the group nothing is dispatched, so Hyprland has nothing to
-- reject and nothing to report.
for index = 3, 5 do
  check(switches_for(two_window_group, index) == nil,
    "window " .. index .. " of a two-window group dispatches nothing")
end

check(switches_for({ group = nil }, 1) == nil, "an ungrouped window dispatches nothing")
check(switches_for(nil, 1) == nil, "no focused window dispatches nothing")
LUA
) || fail "group window bindings guard the group size and stay runnable from the menu" "$output"

printf '%s\n' "$output"
