#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

HOME="$(mktemp -d)" OMARCHY_PATH="$ROOT" lua <<'LUA' || fail "SUPER + J split toggle loads under a Hyprland stub"
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
local split_toggle

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
  bind = function(keys, dispatcher)
    if keys == "SUPER + J" then
      split_toggle = dispatcher
    end
  end,
  dispatch = function(dispatcher)
    table.insert(dispatched, dispatcher)
  end,
  get_active_special_workspace = function()
    return nil
  end,
  get_active_workspace = function()
    return { tiled_layout = "dwindle", windows = 2 }
  end
}

require("default.hypr.helpers")
require("default.hypr.bindings.tiling")

assert(type(split_toggle) == "function", "SUPER + J binds a layout-aware function")

split_toggle()
assert(#dispatched == 1)
assert(dispatched[1].kind == "layout")
assert(dispatched[1].msg == "togglesplit")

dispatched = {}
hl.get_active_workspace = function()
  return { tiled_layout = "scrolling", windows = 2 }
end
split_toggle()
assert(#dispatched == 1)
assert(dispatched[1].kind == "layout")
assert(dispatched[1].msg == "consume_or_expel next")

dispatched = {}
hl.get_active_workspace = function()
  return { tiled_layout = "scrolling", windows = 1 }
end
split_toggle()
assert(#dispatched == 0)

dispatched = {}
hl.get_active_workspace = function()
  return { tiled_layout = "master", windows = 2 }
end
split_toggle()
assert(#dispatched == 0)

dispatched = {}
hl.get_active_workspace = function()
  return nil
end
split_toggle()
assert(#dispatched == 0)

dispatched = {}
hl.get_active_special_workspace = function()
  return { tiled_layout = "scrolling", windows = 2 }
end
hl.get_active_workspace = function()
  error("must prefer the special workspace")
end
split_toggle()
assert(#dispatched == 1)
assert(dispatched[1].msg == "consume_or_expel next")
LUA

pass "SUPER + J dispatches togglesplit on dwindle and consume_or_expel on scrolling"
