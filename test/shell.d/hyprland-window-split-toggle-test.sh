#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

# base-test.sh does not set -e. lua without "-" exits 0 when an assert
# fails, so the assertions have to fail the file themselves.
HOME="$(mktemp -d)" OMARCHY_PATH="$ROOT" lua - <<'LUA' || fail "SUPER + J chooses a layout message the active layout understands"
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

local dispatched = {}
local outcomes = {}

local function reset(layout, windows)
  dispatched = {}
  outcomes = {}
  hl.get_active_special_workspace = function()
    return nil
  end
  hl.get_active_workspace = function()
    return { tiled_layout = layout, windows = windows or 2 }
  end
end

hl = {
  dsp = {
    layout = function(msg)
      return { kind = "layout", msg = msg }
    end,
    exec_cmd = function(command)
      return { kind = "exec", arg = command }
    end,
    window = proxy(),
    focus = proxy(),
    workspace = proxy(),
    group = proxy(),
  },
  bind = function() end,
  unbind = function() end,
  dispatch = function(dispatcher)
    table.insert(dispatched, dispatcher.msg)
    return outcomes[dispatcher.msg] or { ok = true, code = "ok" }
  end,
  get_active_special_workspace = function()
    return nil
  end,
  get_active_workspace = function()
    return { tiled_layout = "dwindle", windows = 2 }
  end,
  on = function() end,
  exec_cmd = function() end,
}

require("default.hypr.helpers")
require("default.hypr.bindings.tiling")

local function messages()
  return table.concat(dispatched, ", ")
end

reset("dwindle")
o.toggle_window_split()
assert(messages() == "togglesplit", "dwindle still toggles the split, got " .. messages())

reset("scrolling")
outcomes["consume_or_expel next"] = { ok = true, code = "ok" }
o.toggle_window_split()
assert(messages() == "consume_or_expel next", "a column to the right is enough, got " .. messages())

reset("scrolling")
outcomes["consume_or_expel next"] = { ok = false, code = "not_found", level = "warning" }
o.toggle_window_split()
assert(messages() == "consume_or_expel next, consume_or_expel prev", "the last column falls back to the previous one, got " .. messages())

reset("scrolling")
outcomes["consume_or_expel next"] = { ok = false, code = "no_target", level = "warning" }
o.toggle_window_split()
assert(messages() == "consume_or_expel next", "a miss that is not a missing column does not try the other way, got " .. messages())

reset("master")
o.toggle_window_split()
assert(messages() == "", "master is left alone, got " .. messages())

reset("scrolling")
hl.get_active_workspace = function()
  return nil
end
o.toggle_window_split()
assert(messages() == "", "no workspace dispatches nothing, got " .. messages())

reset("scrolling")
hl.get_active_special_workspace = function()
  return { tiled_layout = "dwindle", windows = 2 }
end
hl.get_active_workspace = function()
  error("the open special workspace is the one the layout message hits")
end
o.toggle_window_split()
assert(messages() == "togglesplit", "an open dwindle scratchpad still toggles its split, got " .. messages())

reset("dwindle")
hl.get_active_special_workspace = function()
  return { tiled_layout = "scrolling", windows = 2 }
end
outcomes["consume_or_expel next"] = { ok = false, code = "not_found", level = "warning" }
hl.get_active_workspace = function()
  error("the open special workspace is the one the layout message hits")
end
o.toggle_window_split()
assert(messages() == "consume_or_expel next, consume_or_expel prev", "an open scrolling scratchpad uses consume or expel, got " .. messages())

assert(o.bind_commands[o.toggle_window_split] == "hyprctl eval 'o.toggle_window_split()'", "the keybindings menu can replay the bind")
LUA

pass "SUPER + J toggles a dwindle split and stacks or unstacks a scrolling column"
