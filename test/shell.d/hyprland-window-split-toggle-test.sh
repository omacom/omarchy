#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

# lua - so a failed assert fails the file: lua ignores errors in a chunk it reads
# from stdin without a script argument.
OMARCHY_PATH="$ROOT" lua - <<'LUA' || fail "SUPER + J toggles the split only on dwindle"
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local binds, ran = {}, {}
local workspace, special

-- tiling.lua loads whole, so dispatchers nest, as in hl.dsp.window.close().
local function dsp(path)
  return setmetatable({}, {
    __index = function(_, name) return dsp(path and path .. "." .. name or name) end,
    __call = function(_, arg) return { dsp = path, arg = arg } end,
  })
end

hl = setmetatable({
  dsp = dsp(),
  bind = function(keys, dispatcher, opts)
    binds[keys] = dispatcher
  end,
  exec_cmd = function(command) table.insert(ran, command) end,
  dispatch = function(dispatcher) table.insert(ran, dispatcher.dsp .. " " .. dispatcher.arg) end,
  get_active_workspace = function() return workspace end,
  get_active_special_workspace = function() return special end,
}, {
  __index = function()
    return function() return {} end
  end,
})

require("default.hypr.helpers")
dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bindings/tiling.lua")

local toggle = binds["SUPER + J"]
assert(toggle == o.toggle_window_split, "SUPER + J binds the split toggle")
assert(o.bind_commands[toggle] == "hyprctl eval 'o.toggle_window_split()'", "the keybindings menu can run the split toggle")

local function press()
  ran = {}
  toggle()
  return table.concat(ran, "\n")
end

workspace = { tiled_layout = "dwindle" }
assert(press() == "layout togglesplit", "dwindle toggles the split")

workspace = { tiled_layout = "scrolling" }
assert(press() == [[omarchy-notification-send -g 󱂬 'Can'\''t toggle window split in the scrolling layout']],
  "scrolling explains why nothing happened instead of raising a Lua error")

special = { tiled_layout = "dwindle" }
assert(press() == "layout togglesplit", "an open special workspace decides, as it gets the layout message")

workspace, special = { tiled_layout = "dwindle" }, { tiled_layout = "scrolling" }
assert(press():find("^omarchy%-notification%-send"), "a scrolling special workspace over dwindle explains too")

workspace, special = nil, nil
assert(press() == "layout togglesplit", "with no workspace to read, Hyprland decides")
LUA

pass "SUPER + J toggles the split on dwindle and explains why not on other layouts"
