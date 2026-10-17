#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

# SUPER + J dispatches togglesplit, a dwindle-only layout message. On a
# scrolling or floating workspace the dispatch is a Lua error that lands in
# `hyprctl configerrors` (#15642), so the bind must dispatch only on dwindle.

load_bindings() {
  OMARCHY_PATH="$ROOT" lua <<'LUA'
local bind_calls = {}
local dispatch_calls = {}
local active_workspace = nil

local function dsp_proxy(path)
  return setmetatable({}, {
    __index = function(_, key)
      return dsp_proxy(path .. "." .. tostring(key))
    end,
    __call = function(_, ...)
      return { name = path, args = { ... } }
    end,
  })
end

hl = {
  get_active_workspace = function()
    return active_workspace
  end,
  dispatch = function(dispatcher)
    table.insert(dispatch_calls, dispatcher)
  end,
  bind = function(keys, dispatcher, opts)
    table.insert(bind_calls, { keys = keys, dispatcher = dispatcher, opts = opts or {} })
  end,
  dsp = dsp_proxy("hl.dsp"),
}

o = {
  bind_commands = {},
  -- Same signature as the real o.bind: the description comes before the
  -- dispatcher, and a string dispatcher runs as a command.
  bind = function(keys, description, dispatcher, options)
    if type(dispatcher) == "string" then
      dispatcher = hl.dsp.exec_cmd(dispatcher)
    end
    local opts = options or {}
    opts.description = description
    hl.bind(keys, dispatcher, opts)
  end,
}

dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bindings/tiling.lua")

-- The SUPER + J bind and what pressing it now does, one line each:
-- registration, dispatch behavior per active-workspace layout, menu fallback.
local function find_bind()
  for _, call in ipairs(bind_calls) do
    if call.keys == "SUPER + J" then
      return call
    end
  end
  return nil
end

local bind = find_bind()
assert(bind ~= nil, "SUPER + J is still bound")
assert(type(bind.dispatcher) == "function", "SUPER + J runs a layout-aware function")
assert(bind.opts.description == "Toggle window split", "SUPER + J keeps its description")

local function press(layout)
  dispatch_calls = {}
  active_workspace = layout and { tiled_layout = layout } or nil
  bind.dispatcher()
  return #dispatch_calls
end

-- Registration line.
print(string.format("bind %s %s", type(bind.dispatcher), tostring(o.bind_commands[bind.dispatcher] ~= nil)))

-- Dispatch behavior lines: one per layout.
print(string.format("dispatch dwindle %d", press("dwindle")))
assert(dispatch_calls[1] ~= nil and dispatch_calls[1].name == "hl.dsp.layout" and
  dispatch_calls[1].args[1] == "togglesplit", "the dwindle press dispatches togglesplit")
print(string.format("dispatch scrolling %d", press("scrolling")))
print(string.format("dispatch floating %d", press("unknown")))
print(string.format("dispatch none %d", press(nil)))

-- The keybindings menu runs a Lua bind through o.bind_commands; the fallback
-- must stay the plain dispatch, or the row loses its command.
assert(o.bind_commands[bind.dispatcher] == "hyprctl dispatch togglesplit",
  "the keybindings menu fallback stays the plain togglesplit dispatch")
print("menu-fallback ok")
LUA
}

output=$(load_bindings)

grep -qx "bind function true" <<<"$output" || \
  fail "SUPER + J is bound to a layout-aware function with a menu fallback" "$output"
pass "SUPER + J is bound to a layout-aware function with a menu fallback"

grep -qx "dispatch dwindle 1" <<<"$output" || \
  fail "SUPER + J dispatches togglesplit on a dwindle workspace" "$output"
pass "SUPER + J dispatches togglesplit on a dwindle workspace"

grep -qx "dispatch scrolling 0" <<<"$output" || \
  fail "SUPER + J stays inert on a scrolling workspace" "$output"
pass "SUPER + J stays inert on a scrolling workspace"

grep -qx "dispatch floating 0" <<<"$output" || \
  fail "SUPER + J stays inert on a floating workspace" "$output"
pass "SUPER + J stays inert on a floating workspace"

grep -qx "dispatch none 0" <<<"$output" || \
  fail "SUPER + J stays inert with no active workspace" "$output"
pass "SUPER + J stays inert with no active workspace"

grep -qx "menu-fallback ok" <<<"$output" || \
  fail "the keybindings menu keeps a runnable fallback for SUPER + J" "$output"
pass "the keybindings menu keeps a runnable fallback for SUPER + J"
