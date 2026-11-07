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

-- Only omarchy-capture-region's slurp carries the picker marker.
local processes = {
  ["101"] = { comm = "slurp\n", environ = "PATH=/usr/bin\0OMARCHY_CAPTURE_REGION_PICKER=1\0" },
  ["202"] = { comm = "wl-kbptr\n", environ = "OMARCHY_CAPTURE_REGION_PICKER=1\0" },
  ["303"] = { comm = "slurp\n", environ = "PATH=/usr/bin\0" },
}
local real_open = io.open
io.open = function(path, mode)
  local pid, file = path:match("^/proc/(%d+)/(%a+)$")
  if not pid then
    return real_open(path, mode)
  end
  local process = processes[pid]
  local contents = process and process[file]
  if not contents then
    return nil
  end
  return {
    read = function(_, format) return format == "*l" and contents:match("[^\n]*") or contents end,
    close = function() end,
  }
end

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

local function layer(address, pid)
  return { address = address, namespace = "selection", pid = pid }
end

for _, other in ipairs({ layer("wl-kbptr", 202), layer("plain-slurp", 303), layer("gone", 404) }) do
  handlers["layer.opened"](other)
end
assert(enabled_picker_binds() == 0, "another client's selection layer gets none of the picker's binds")
for _, other in ipairs({ layer("wl-kbptr"), layer("plain-slurp"), layer("gone") }) do
  handlers["layer.closed"](other)
end

local function use_picker()
  handlers["layer.opened"](layer("monitor-1", 101))
  handlers["layer.opened"](layer("monitor-1", 101))
  handlers["layer.opened"](layer("monitor-2", 101))
  assert(enabled_picker_binds() == 8, "the picker enables its eight binds while open")

  handlers["layer.closed"](layer("monitor-1"))
  handlers["layer.closed"](layer("unknown"))
  assert(enabled_picker_binds() == 8, "the picker keeps its binds while a layer is still open")

  handlers["layer.closed"](layer("monitor-2"))
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

handlers["layer.opened"](layer("monitor-1", 101))
hl.unbind("RETURN")
handlers["layer.closed"](layer("monitor-1"))
assert(enabled_picker_binds() == 0, "the picker closes cleanly after a chord is unbound while open")
LUA

pass "screenshot picker leaves the user's binds on its keys alone"
