#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

if ! output=$(OMARCHY_PATH="$ROOT" lua - 2>&1 <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local function proxy()
  return setmetatable({}, {
    __index = function(self, key)
      local value = proxy()
      rawset(self, key, value)
      return value
    end,
    __call = function()
      return {}
    end,
  })
end

local bindings = {}
local dispatched = {}
local workspace = { tiled_layout = "scrolling" }
local special_workspace = nil
local dsp = proxy()
dsp.layout = function(message)
  return "layout:" .. message
end

hl = setmetatable({
  dsp = dsp,
  bind = function(keys, dispatcher)
    bindings[keys] = dispatcher
  end,
  dispatch = function(dispatcher)
    table.insert(dispatched, dispatcher)
  end,
  get_active_workspace = function()
    return workspace
  end,
  get_active_special_workspace = function()
    return special_workspace
  end,
}, {
  __index = function()
    return function() end
  end,
})

require("default.hypr.helpers")
require("default.hypr.bindings.tiling")

local toggle_split = bindings["SUPER + J"]
assert(type(toggle_split) == "function", "Super+J must check the layout at keypress time")
assert(o.bind_commands[toggle_split] == "hyprctl eval 'o.toggle_window_split()'", "the menu replays the layout-aware toggle")

local function check(normal, special, expected, description)
  workspace = normal and { tiled_layout = normal } or nil
  special_workspace = special and { tiled_layout = special } or nil
  dispatched = {}
  toggle_split()
  assert(#dispatched == expected, description)
  if expected == 1 then
    assert(dispatched[1] == "layout:togglesplit", description .. ": wrong dispatcher")
  end
end

check("scrolling", nil, 0, "scrolling workspace does not dispatch togglesplit")
check("dwindle", nil, 1, "switching to dwindle enables togglesplit")
check("scrolling", nil, 0, "switching back to scrolling disables togglesplit")
check("dwindle", "scrolling", 0, "scrolling special workspace overrides underlying dwindle workspace")
check("scrolling", "dwindle", 1, "dwindle special workspace overrides underlying scrolling workspace")
check("master", nil, 0, "other layouts do not dispatch togglesplit")
check(nil, nil, 0, "missing workspace does not dispatch togglesplit")
LUA
); then
  fail "toggle split binding assertions failed" "$output"
fi

[[ -z $output ]] || fail "toggle split binding produces no output" "$output"
pass "toggle split only dispatches in a Dwindle workspace"
