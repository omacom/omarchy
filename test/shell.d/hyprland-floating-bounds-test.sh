#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

OMARCHY_PATH="$ROOT" lua - <<'LUA' || fail "a floating window dropped under the top bar keeps its titlebar in reach"
local handlers, binds, timers, dispatched = {}, {}, {}, {}
local active, cursor = nil, { x = 0, y = 0 }

-- Two screens stacked: the top bar reserves 26 at the top of each.
local upper = { x = 0, y = 0, width = 1920, height = 1080, scale = 1, transform = 0, reserved = { top = 26 } }
local lower = { x = 0, y = 1080, width = 1920, height = 1080, scale = 1, transform = 0, reserved = { top = 26 } }
local config = { ["plugin.hyprbars.bar_height"] = 30, ["general.border_size"] = 2 }

hl = {
  on = function(event, callback) handlers[event] = callback end,
  bind = function(keys, callback) table.insert(binds, callback) end,
  timer = function(callback) table.insert(timers, callback) end,
  get_active_window = function() return active end,
  get_cursor_pos = function() return cursor end,
  get_monitors = function() return { upper, lower } end,
  get_config = function(key) return config[key] end,
  plugin = { hyprbars = {} },
  dispatch = function(dispatcher)
    table.insert(dispatched, dispatcher)
    if dispatcher.kind == "move" then dispatcher.window.at = { x = dispatcher.x, y = dispatcher.y } end
  end,
  dsp = { window = {
    move = function(args) args.kind = "move"; return args end,
    fullscreen = function(args) args.kind = "fullscreen"; return args end,
  } },
}

dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")
o = o or {}
local bounds = require("default.hypr.floating-bounds")

local function window(y, extra)
  local w = { address = "0xabc", floating = true, fullscreen = 0, workspace = { id = 1 }, monitor = upper,
    tags = { "omarchy-floating-workspace" }, class = "foot", at = { x = 400, y = 300 }, size = { x = 800, y = 600 } }
  for key, value in pairs(extra or {}) do w[key] = value end
  w.at = { x = 400, y = y }
  return w
end

-- The window becomes active as a drag starts, and again where it is dropped.
local function drop(w, to_y, pointer)
  dispatched = {}
  active = w
  handlers["window.active"]()
  for _, run in ipairs(timers) do run() end
  timers = {}
  w.at = { x = w.at.x, y = to_y }
  cursor = pointer or { x = w.at.x + 100, y = to_y - 10 }
  handlers["window.active"]()
  for _, run in ipairs(timers) do run() end
  timers = {}
  return dispatched
end

local function click(pointer)
  dispatched = {}
  cursor = pointer
  binds[1]()
  for _, run in ipairs(timers) do run() end
  timers = {}
  return dispatched
end

assert(#drop(window(300), 40) == 0, "nothing moves until the toggle switches it on")
bounds.keep_title_bar = true

local moved = drop(window(300), 40)
assert(#moved == 1 and moved[1].kind == "move" and moved[1].y == 26 + 2 + 30,
  "a titlebar dropped under the top bar comes down to just below it")

assert(#drop(window(300), 200) == 0, "a window dropped in the clear stays where it was put")
assert(#click({ x = 900, y = 10 }) == 0, "a click on the bar afterwards moves nothing")

local framed = drop(window(300, { tags = { "omarchy-floating-workspace", "omarchy-self-framed*" } }), 10, { x = 500, y = 30 })
assert(#framed == 1 and framed[1].y == 26 + 2, "an app drawing its own header has no titlebar to clear")

local straddling = drop(window(1300, { monitor = lower }), 1070, { x = 500, y = 1060 })
assert(#straddling == 0, "a titlebar showing on the screen above is left where it is")

assert(#drop(window(300, { workspace = { id = -98 } }), 10) == 0, "the scratchpad is left to its own rules")
assert(#drop(window(300, { tags = {} }), 10) == 0, "a window on a tiled workspace is left to the layout")

local w = window(300)
active = w
handlers["window.active"](); for _, run in ipairs(timers) do run() end; timers = {}
w.at = { x = 400, y = 40 }; w.size = { x = 900, y = 600 }
dispatched = {}
handlers["window.active"](); for _, run in ipairs(timers) do run() end; timers = {}
assert(#dispatched == 0, "a resize from the top edge is not taken for a drop")

assert(#drop(window(300), 40, { x = 50, y = 900 }) == 0, "a window moved while the pointer is elsewhere is not taken for a drop")

LUA
pass "a floating window dropped under the top bar keeps its titlebar in reach"
