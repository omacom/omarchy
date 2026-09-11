#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
require_command lua

lua <<'LUA' || exit 1
local bindings, events, timers = {}, {}, {}
local active
o = {
  bind = function(keys, description, action) bindings[keys] = action end,
  bind_toggle = function() end,
}
hl = {
  on = function() end,
  get_active_window = function() return active end,
  dsp = { send_key_state = function(event) return event end },
  dispatch = function(event)
    events[#events + 1] = event.mods .. ":" .. event.key .. ":" .. event.state
  end,
  timer = function(callback, options)
    assert(options.type == "oneshot" and options.timeout > 0)
    timers[#timers + 1] = callback
  end,
}
dofile(os.getenv("ROOT") .. "/default/hypr/bindings/utilities.lua")
local invoke = assert(bindings["SUPER + BACKSPACE"])
assert(bindings["SUPER + ALT + BACKSPACE"] == "omarchy-hyprland-window-transparency-toggle")
local function drain()
  while #timers > 0 do table.remove(timers, 1)() end
end
local function check(tags, expected)
  events = {}
  active = { address = "0x1", tags = tags }
  invoke()
  invoke() -- A repeated press must not interleave another sequence.
  drain()
  assert(table.concat(events, ",") == expected, table.concat(events, ","))
end
local graphical = "SHIFT:HOME:down,SHIFT:HOME:up,:BACKSPACE:down,:BACKSPACE:up"
local terminal = "CTRL:U:down,CTRL:U:up"
check({ "terminal*" }, terminal)
check({ "terminal" }, terminal)
check({ "not-terminal*" }, graphical)
check(nil, graphical)
events = {}
active = nil
invoke()
assert(#events == 0 and #timers == 0)
for _, next_window in ipairs({ { address = "0x2" }, false }) do
  events = {}
  active = { address = "0x1" }
  invoke()
  active = next_window or nil
  drain()
  assert(table.concat(events, ",") == "SHIFT:HOME:down,SHIFT:HOME:up")
  check({}, graphical) -- Cancellation must allow subsequent invocations.
end
print("ok - line deletion routes terminal and graphical events, balances releases, and guards overlap and focus changes")
LUA
