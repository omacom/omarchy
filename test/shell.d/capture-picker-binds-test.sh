#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

ROOT="$ROOT" lua -E - <<'LUA' || fail "screenshot picker leaves the user's binds on its keys alone"
local binds = {}
local handlers = {}

-- Like Hyprland's, unbinding removes every bind on the chord and expires their handles.
local function unbind(keys)
  for index = #binds, 1, -1 do
    if binds[index].keys == keys then
      binds[index].expired = true
      table.remove(binds, index)
    end
  end
end

local function bind(keys)
  local keybind = { keys = keys, enabled = true }

  -- Hyprland's methods crash on an expired handle; only tostring() reports it.
  local function live(self)
    assert(not self.expired, "called a method on an expired handle: " .. self.keys)
  end

  function keybind:set_enabled(enabled)
    live(self)
    self.enabled = enabled
  end

  function keybind:unbind()
    live(self)
    unbind(self.keys)
  end

  table.insert(binds, keybind)
  return setmetatable(keybind, {
    __tostring = function(self)
      return self.expired and "HL.Keybind(expired)" or "HL.Keybind(live)"
    end,
  })
end

hl = {
  bind = bind,
  unbind = unbind,
  dsp = { exec_cmd = function(command) return command end },
  on = function(event, handler) handlers[event] = handler end,
}
o = setmetatable({}, { __index = function() return function() end end })

dofile(os.getenv("ROOT") .. "/default/hypr/bindings/utilities.lua")

local user = bind("CTRL + TAB")

local function enabled_picker_binds()
  local count = 0
  for _, keybind in ipairs(binds) do
    if keybind ~= user and keybind.enabled then
      count = count + 1
    end
  end
  return count
end

local function use_picker()
  handlers["layer.opened"]({ namespace = "selection" })
  handlers["layer.opened"]({ namespace = "selection" })
  assert(enabled_picker_binds() == 8, "the picker enables its eight binds while open")

  handlers["layer.closed"]({ namespace = "selection" })
  assert(enabled_picker_binds() == 8, "the picker keeps its binds while a layer is still open")

  handlers["layer.closed"]({ namespace = "selection" })
  assert(enabled_picker_binds() == 0, "the picker disables its binds once every layer closes")
end

use_picker()
use_picker()

local kept = false
for _, keybind in ipairs(binds) do
  kept = kept or keybind == user
end
assert(kept and user.enabled, "the user's own CTRL + TAB survives the picker")
assert(#binds == 9, "the picker reuses its binds rather than adding more each time")

hl.unbind("TAB")
use_picker()
assert(#binds == 9, "the picker binds a chord again after something else unbinds it")

handlers["layer.opened"]({ namespace = "selection" })
hl.unbind("RETURN")
handlers["layer.closed"]({ namespace = "selection" })
assert(enabled_picker_binds() == 0, "the picker closes cleanly after a chord is unbound while open")
LUA

pass "screenshot picker leaves the user's binds on its keys alone"
