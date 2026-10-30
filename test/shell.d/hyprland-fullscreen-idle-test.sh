#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# A game holds off the screensaver and lock while it is fullscreen, whichever
# launcher started it. Only true fullscreen counts: Full width (maximized) is
# a tiling choice, not a game. The window rules are loaded as Hyprland would,
# and the last matching rule with idle_inhibit decides, as it does there.
# base-test.sh does not set -e, so the assertions have to fail the file
# themselves rather than leaving the pass below to run regardless.
HOME="$tmpdir" OMARCHY_PATH="$ROOT" lua - <<'LUA' || fail "fullscreen windows from any launcher hold off idle"
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local rules = {}

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

hl = setmetatable({
  dsp = proxy(),
  window_rule = function(rule) table.insert(rules, rule) end,
}, {
  __index = function()
    return function()
      return {}
    end
  end,
})

require("default.hypr.helpers")
require("default.hypr.windows")

-- Plain classes only: ".*" matches any, anything else must match exactly.
local function matches(match, window)
  for key, value in pairs(match) do
    if key == "class" or key == "title" then
      if value ~= ".*" and value ~= window[key] then
        return false
      end
    elseif key == "tag" then
      if not (window.tags or {})[value] then
        return false
      end
    elseif window[key] ~= value then
      return false
    end
  end
  return true
end

local function idle_inhibit(window)
  window.title = window.title or ""
  window.fullscreen_state_internal = window.fullscreen_state_internal or 0
  local mode = nil
  for _, rule in ipairs(rules) do
    if rule.idle_inhibit and matches(rule.match, window) then
      mode = rule.idle_inhibit
    end
  end
  return mode
end

local function expect(window, want, message)
  local got = idle_inhibit(window)
  assert(got == want, message .. ": got " .. tostring(got) .. ", want " .. tostring(want))
end

expect({ class = "rocketleague.exe", fullscreen_state_internal = 2 }, "fullscreen",
  "a fullscreen game from Heroic holds off idle")
expect({ class = "steam_app_252950", fullscreen_state_internal = 2 }, "fullscreen",
  "a fullscreen Steam game holds off idle")
expect({ class = "rocketleague.exe" }, nil, "a windowed game leaves idle alone")
expect({ class = "rocketleague.exe", fullscreen_state_internal = 1 }, nil,
  "a Full width window leaves idle alone")

expect({ class = "steam" }, "fullscreen", "Steam keeps its own rule")
expect({ class = "com.libretro.RetroArch" }, "fullscreen", "RetroArch keeps its own rule")
expect({ class = "GeForceNOW" }, "fullscreen", "GeForce NOW keeps its own rule")
expect({ class = "rocketleague.exe", tags = { noidle = true } }, "always", "noidle windows still always hold off idle")
LUA
pass "fullscreen windows from any launcher hold off idle"
