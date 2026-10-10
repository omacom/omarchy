#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
require_command lua

lua <<'LUA'
local root = os.getenv("ROOT")
package.loaded["default.hypr.paths"] = { omarchy_path = root }
local bindings

local function reset()
  bindings = {}
  o = {}
  hl = {
    dsp = { exec_cmd = function(command) return { command = command } end },
    bind = function(keys, dispatcher, opts)
      assert(opts.append == nil, "append is an Omarchy option, not a Hyprland option")
      local binding = { keys = keys, dispatcher = dispatcher, active = true, enabled = true }
      for key, value in pairs(opts) do binding[key] = value end
      bindings[#bindings + 1] = binding
      local handle = setmetatable({
        is_enabled = function()
          assert(binding.active, "Hyprland 0.56.2 crashes when an expired handle is queried")
          return binding.enabled
        end,
        set_enabled = function(_, enabled)
          assert(binding.active, "an expired handle must not be modified")
          binding.enabled = enabled
        end,
        unbind = function() error("per-handle unbind is key-wide on Hyprland 0.56.2") end,
      }, {
        __tostring = function()
          return binding.active and "HL.Keybind(mock)" or "HL.Keybind(expired)"
        end,
      })
      binding.handle = handle
      return handle
    end,
    unbind = function(keys)
      for _, binding in ipairs(bindings) do
        if binding.keys:gsub("%s", ""):lower() == keys:gsub("%s", ""):lower() then
          binding.active = false
        end
      end
    end,
  }
  dofile(root .. "/default/hypr/helpers.lua")
end

local function active()
  local result = {}
  for _, binding in ipairs(bindings) do
    if binding.active then result[#result + 1] = binding end
  end
  return result
end

reset()
hl.bind("SUPER + F12", hl.dsp.exec_cmd("old"), { description = "raw" })
o.rebind("SUPER + F12", "replacement", "new")
assert(#active() == 1 and active()[1].description == "replacement")
print("ok - o.rebind replaces direct hl.bind calls")

reset()
o.bind("F9", "press", "start")
o.bind("F9", "release", "stop", { release = true })
hl.unbind("F9")
o.bind("F9", "custom release", "custom", { release = true })
assert(#active() == 1 and active()[1].description == "custom release")
print("ok - explicit hl.unbind does not resurrect a removed event or query expired handles")

reset()
o.bind("ALT + TAB", "cycle", { native = "cycle" })
o.bind("ALT + TAB", "raise", { native = "raise" }, { append = true })
o.bind("ALT + TAB", "release", "old", { release = true })
o.bind("ALT + TAB", "new release", "new", { release = true })
assert(#active() == 3)
assert(active()[1].description == "cycle" and active()[2].description == "raise")
assert(active()[3].description == "new release")
print("ok - a release override preserves every stacked press action in order")
o.bind("ALT + TAB", "replacement", { native = "new" })
assert(#active() == 2)
assert(active()[1].description == "new release" and active()[2].description == "replacement")
print("ok - a native dispatcher override replaces the entire matching stack")

reset()
o.bind("F10", "press", function() end)
o.bind("F10", "long press", function() end, { long_press = true })
o.bind("F10", "release", function() end, { release = true })
o.bind("F10", "new long press", function() end, { long_press = true })
assert(#active() == 3)
assert(active()[1].description == "press" and active()[2].description == "release")
assert(active()[3].description == "new long press")
print("ok - press, release and long press remain independent events")

reset()
o.bind("F11", "press", "press")
bindings[1].handle:set_enabled(false)
o.bind("F11", "release", "release", { release = true })
o.bind("F11", "new release", "new", { release = true })
assert(#active() == 2 and not active()[1].enabled)
assert(active()[2].description == "new release")
print("ok - rebuilding a surviving event preserves its disabled state")

reset()
local options = { locked = true }
o.bind("F9", "press", "press", options)
options.release = true
o.bind("F9", "release", "release", options)
o.bind("F9", "new release", "new", { release = true })
assert(options.description == nil and options.append == nil)
assert(#active() == 2 and not active()[1].release and active()[1].locked)
assert(active()[1].description == "press")
print("ok - caller options are not mutated and survivors keep their original options")

reset()
o.bind("SUPER + SHIFT + F", "old", "old")
hl.unbind("SUPER + SHIFT + F")
hl.bind("SHIFT + SUPER + F", hl.dsp.exec_cmd("raw"), { description = "raw" })
o.rebind("SHIFT + SUPER + F", "new", "new")
assert(#active() == 1 and active()[1].description == "new")
print("ok - o.rebind removes direct bindings even when a recorded spelling has expired")

reset()
o.bind("F12", "first", "first")
o.bind("F12", "second", function() end, { append = true })
assert(#active() == 2)
o.bind("F12", "third", "third")
assert(#active() == 1 and active()[1].description == "third")
print("ok - commands and callbacks only stack when append is explicit")
LUA
