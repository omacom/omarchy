#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

lua - "$ROOT" <<'LUA'
local bindings = {}
local workspace, special_workspace
local dispatched = {}

-- Other bindings in tiling.lua only need dispatcher placeholders.
local dispatcher = setmetatable({}, {
  __index = function(self) return self end,
  __call = function() return {} end,
})

hl = {
  dsp = setmetatable({
    layout = function(message) return message end,
  }, { __index = function() return dispatcher end }),
  get_active_workspace = function() return workspace end,
  get_active_special_workspace = function() return special_workspace end,
  dispatch = function(action) table.insert(dispatched, action) end,
}
o = {
  bind = function(keys, description, action) bindings[keys] = action end,
}

dofile(arg[1] .. "/default/hypr/bindings/tiling.lua")
local toggle_split = bindings["SUPER + J"]
assert(type(toggle_split) == "function", "Super+J must check the layout at keypress time")

local function check(normal, special, expected, description)
  workspace = normal and { tiled_layout = normal } or nil
  special_workspace = special and { tiled_layout = special } or nil
  dispatched = {}
  toggle_split()
  assert(#dispatched == expected, description)
  if expected == 1 then
    assert(dispatched[1] == "togglesplit", description .. ": wrong dispatcher")
  end
  print("ok - " .. description)
end

check("scrolling", nil, 0, "scrolling workspace does not dispatch togglesplit")
check("dwindle", nil, 1, "switching to dwindle enables togglesplit")
check("scrolling", nil, 0, "switching back to scrolling disables togglesplit")
check("dwindle", "scrolling", 0, "scrolling scratchpad overrides underlying dwindle workspace")
check("scrolling", "dwindle", 1, "dwindle scratchpad overrides underlying scrolling workspace")
check("master", nil, 0, "other layouts do not dispatch togglesplit")
check(nil, nil, 0, "missing workspace does not dispatch togglesplit")
LUA
