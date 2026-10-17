#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

clipboard="$ROOT/default/hypr/bindings/clipboard.lua"

grep -F 'o.bind("SUPER + C", "Universal copy", universal_clipboard_shortcut("CTRL", "C", "CTRL SHIFT", "C"))' \
  "$clipboard" >/dev/null ||
  fail "Super+C uses Ctrl+C outside terminals and Ctrl+Shift+C in terminals"

require_command lua
lua - "$clipboard" <<'LUA'
local bindings = {}
local active_window
local events
local release

hl = {
  get_active_window = function() return active_window end,
  dsp = { send_key_state = function(event) return event end },
  dispatch = function(event) table.insert(events, event) end,
  timer = function(callback, options)
    assert(options.timeout == 50 and options.type == "oneshot")
    release = callback
  end,
}
o = { bind = function(chord, description, callback) bindings[chord] = callback end }
dofile(arg[1])

local function check(window, mods, description)
  active_window = window
  events = {}
  release = nil
  bindings["SUPER + C"]()
  assert(#events == 1 and release, description .. ": key-down schedules release")
  release()
  assert(#events == 2, description .. ": exactly two key events")
  for index, state in ipairs({ "down", "up" }) do
    local event = events[index]
    assert(event.mods == mods and event.key == "C" and event.state == state,
      description .. ": expected " .. mods .. " + C " .. state)
  end
  print("ok - " .. description)
end

check({ class = "org.omarchy.agent", tags = { "terminal*" } }, "CTRL", "dedicated agent gets Ctrl+C")
for _, title in ipairs({ "~/src/codex-plugins", "vim codex.md", "tail -f codex.log", "codex" }) do
  check({ class = "Alacritty", title = title, tags = { "terminal*" } },
    "CTRL SHIFT", "terminal titled " .. title .. " keeps terminal copy")
end
check({ class = "Alacritty", initialTitle = "Codex", tags = { "terminal" } },
  "CTRL SHIFT", "terminal initial title containing Codex keeps terminal copy")
for _, class in ipairs({ "codex", "org.codex.app", "org.omarchy.agent.codex" }) do
  check({ class = class, tags = { "terminal" } },
    "CTRL SHIFT", "class " .. class .. " keeps terminal copy")
end
check({ class = "Alacritty", initialClass = "org.omarchy.agent", tags = { "terminal" } },
  "CTRL SHIFT", "initial agent class alone keeps terminal copy")
check({ class = "firefox" }, "CTRL", "ordinary window gets Ctrl+C")
check(nil, "CTRL", "no active window gets Ctrl+C")
LUA
