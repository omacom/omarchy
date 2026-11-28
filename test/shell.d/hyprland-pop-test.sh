#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

OMARCHY_PATH="$ROOT" lua - <<'LUA' || fail "a popped-out window is centered again on the monitor it moves to"
local handlers, timers, centered = {}, {}, {}

hl = {
  on = function(event, callback) handlers[event] = callback end,
  timer = function(callback, opts) table.insert(timers, { run = callback, opts = opts }) end,
  dispatch = function(dispatcher) table.insert(centered, dispatcher.window) end,
  dsp = { window = { center = function(args) return args end } },
}

dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")
require("default.hypr.pop")

local left, right = { id = 0 }, { id = 1 }

local function move(tags, from, to)
  timers, centered = {}, {}
  handlers["window.move_to_workspace"]({ address = "0xabc", tags = tags, monitor = from }, { monitor = to })
  for _, timer in ipairs(timers) do timer.run() end
  return centered
end

local moved = move({ "pop" }, left, right)
assert(#moved == 1 and moved[1] == "address:0xabc", "a popped window moved to another monitor is centered there")

-- Centering in the event itself would measure the monitor it is leaving.
timers, centered = {}, {}
handlers["window.move_to_workspace"]({ address = "0xabc", tags = { "pop" }, monitor = left }, { monitor = right })
assert(#centered == 0, "nothing is centered while the move is still in flight")
assert(#timers == 1 and timers[1].opts.type == "oneshot" and timers[1].opts.timeout > 0, "the center waits until the move has landed")

assert(#move({ "pop" }, left, left) == 0, "a move between workspaces on the same monitor keeps where it was put")
assert(#move({ "default-opacity*" }, left, right) == 0, "a window that was not popped out is left alone")
assert(#move({ "pop" }, left, nil) == 0, "a workspace without a monitor is not measured")
LUA
pass "a popped-out window is centered again on the monitor it moves to"
