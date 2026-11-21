#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

OMARCHY_PATH="$ROOT" lua - <<'LUA' || fail "a window moved to another monitor lands on screen there"
local handlers, timers, dispatched, landed = {}, {}, {}, nil
local config = { ["general.border_size"] = 2 }

hl = {
  on = function(event, callback) handlers[event] = callback end,
  timer = function(callback, opts) table.insert(timers, { run = callback, opts = opts }) end,
  dispatch = function(dispatcher) table.insert(dispatched, dispatcher) end,
  get_window = function() return landed end,
  get_config = function(key) return config[key] end,
  plugin = {},
  dsp = {
    window = {
      center = function(args) return { center = args.window } end,
      move = function(args) return { move = args } end,
    },
  },
}

dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")
require("default.hypr.pop")

-- A portrait monitor beside a landscape one, as on a desk with one turned on its side.
local portrait = { id = 0, x = 0, y = 0, width = 1920, height = 1080, scale = 1, transform = 1 }
local landscape = { id = 1, x = 1080, y = 684, width = 1920, height = 1080, scale = 1, transform = 0, reserved = { top = 26 } }

local function move(window, from, to)
  timers, dispatched = {}, {}
  window.address = "0xabc"
  window.floating = window.floating ~= false
  window.size = window.size or { x = 1100, y = 734 }
  landed = window
  landed.monitor = to
  handlers["window.move_to_workspace"]({ address = window.address, tags = window.tags, monitor = from }, { monitor = to })
  for _, timer in ipairs(timers) do timer.run() end
  return dispatched
end

local moved = move({ tags = { "pop" }, at = { x = 1100, y = 700 } }, portrait, landscape)
assert(#moved == 1 and moved[1].center == "address:0xabc", "a popped window moved to another monitor is centered there")

-- Placing it in the event itself would measure the monitor it is leaving.
timers, dispatched = {}, {}
handlers["window.move_to_workspace"]({ address = "0xabc", tags = { "pop" }, monitor = portrait }, { monitor = landscape })
assert(#dispatched == 0, "nothing is placed while the move is still in flight")
assert(#timers == 1 and timers[1].opts.type == "oneshot" and timers[1].opts.timeout > 0, "the window is placed once the move has landed")

-- Minimized from low on the portrait monitor and brought back on the landscape one,
-- Hyprland keeps its offset and puts it below the bottom of the screen.
moved = move({ at = { x = 2121, y = 2243 } }, portrait, landscape)
assert(#moved == 1 and moved[1].move.x == 1898 and moved[1].move.y == 1028 and moved[1].move.relative == false,
  "a window carried off the bottom of a smaller screen is moved just far enough to be on it")

moved = move({ at = { x = 1080, y = 600 }, size = { x = 2400, y = 1400 } }, portrait, landscape)
assert(moved[1].move.x == 1082 and moved[1].move.y == 712, "a window larger than the screen keeps its top-left corner on it, below the bar")

-- A floating workspace draws its titlebar above the window, outside its position.
hl.plugin.hyprbars, config["plugin.hyprbars.bar_height"] = {}, 30
moved = move({ tags = { "omarchy-floating-workspace" }, at = { x = 1500, y = 600 } }, portrait, landscape)
assert(moved[1].move.x == 1500 and moved[1].move.y == 742, "a window with a titlebar lands with the titlebar below the bar")
hl.plugin.hyprbars, config["plugin.hyprbars.bar_height"] = nil, nil

assert(#move({ at = { x = 1500, y = 800 } }, portrait, landscape) == 0, "a window already on screen stays where it landed")
assert(#move({ at = { x = 2121, y = 2243 }, fullscreen = 1 }, portrait, landscape) == 0, "a maximized window is left to Hyprland")
assert(#move({ at = { x = 2121, y = 2243 }, floating = false }, portrait, landscape) == 0, "a tiled window is left to the layout")

-- The minimized windows' store can move monitors with a window in it.
moved = move({ at = { x = 2121, y = 2243 } }, landscape, landscape)
assert(#moved == 1 and moved[1].move.y == 1028, "a window brought back entirely out of sight on the same monitor is moved on screen")
assert(#move({ tags = { "pop" }, at = { x = 2500, y = 1500 } }, landscape, landscape) == 0,
  "a window the user left partly off the edge keeps where it was put")

assert(#move({ tags = { "pop" } }, portrait, nil) == 0, "a workspace without a monitor is not measured")
LUA
pass "a window moved to another monitor lands on screen there"
