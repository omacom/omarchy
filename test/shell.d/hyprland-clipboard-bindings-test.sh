#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

lua - <<'LUA' || fail "universal clipboard shortcuts preserve app and terminal routing"
local bindings, events, timers = {}, {}, {}
local window

o = { bind = function(keys, description, callback) bindings[keys] = callback end }
hl = {
  get_active_window = function() return window end,
  dsp = { send_key_state = function(event) return event end },
  dispatch = function(event) table.insert(events, event) end,
  timer = function(callback, options)
    assert(options.timeout == 50 and options.type == "oneshot")
    table.insert(timers, callback)
  end,
}

dofile(os.getenv("ROOT") .. "/default/hypr/bindings/clipboard.lua")

local function check(active, shortcut, mods, key, description)
  window, events, timers = active, {}, {}
  bindings[shortcut]()
  assert(#events == 1 and #timers == 1, description .. ": one press and release timer")
  timers[1]()
  assert(#events == 2, description .. ": one release")
  for index, state in ipairs({ "down", "up" }) do
    local event = events[index]
    assert(event.mods == mods and event.key == key and event.state == state,
      description .. ": expected " .. mods .. "+" .. key .. " " .. state)
    assert(event.window == nil, description .. ": target stays the focused surface")
  end
end

check({ class = "chatgpt" }, "SUPER + V", "SHIFT", "Insert", "Codex embedded terminal paste")
check({ class = "chatgpt" }, "SUPER + C", "CTRL", "C", "Codex copy")
check({ class = "chatgpt" }, "SUPER + X", "CTRL", "X", "Codex cut")

for _, tags in ipairs({ { "terminal" }, { "other", "terminal*" } }) do
  check({ class = "Alacritty", tags = tags }, "SUPER + V", "SHIFT", "Insert", "terminal paste")
  check({ class = "Alacritty", tags = tags }, "SUPER + C", "CTRL", "Insert", "terminal copy")
  check({ class = "Alacritty", tags = tags }, "SUPER + X", "CTRL", "X", "terminal cut")
end

for _, active in ipairs({ { class = "chromium", tags = {} }, {}, false }) do
  check(active or nil, "SUPER + V", "CTRL", "V", "ordinary window or layer-shell paste")
  check(active or nil, "SUPER + C", "CTRL", "C", "ordinary window or layer-shell copy")
  check(active or nil, "SUPER + X", "CTRL", "X", "ordinary window or layer-shell cut")
end
LUA
pass "universal clipboard shortcuts preserve app and terminal routing"
