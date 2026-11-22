#!/bin/bash

# SUPER + arrows reach floating and popped-out windows and leave them again.
# Runs default/hypr/window-focus.lua against a model of Hyprland whose own
# directional focus, like the real one, only moves between windows of the same
# kind (tiled to tiled, floating to floating).

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

cat >"$tmpdir/test.lua" <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path

local windows, active = {}, nil
local monitor = { id = 0 }
local workspace = { id = 1 }

local function window(address, x, y, w, h, floating, pinned)
  windows[#windows + 1] = {
    address = address, at = { x = x, y = y }, size = { x = w, y = h },
    floating = floating or false, pinned = pinned or false,
    mapped = true, hidden = false, monitor = monitor, workspace = workspace,
  }
end

local function named(address)
  for _, w in ipairs(windows) do
    if w.address == address then return w end
  end
end

-- Hyprland's own move: the window of the same kind most in line that way.
local function native_move(direction)
  local from = named(active)
  local fx, fy = from.at.x + from.size.x / 2, from.at.y + from.size.y / 2
  local best, best_distance
  for _, w in ipairs(windows) do
    if w ~= from and w.floating == from.floating then
      local dx = w.at.x + w.size.x / 2 - fx
      local dy = w.at.y + w.size.y / 2 - fy
      local along = ({ l = -dx, r = dx, u = -dy, d = dy })[direction]
      local across = math.abs(({ l = dy, r = dy, u = dx, d = dx })[direction])
      if along > 0 and (not best_distance or along + 2 * across < best_distance) then
        best, best_distance = w, along + 2 * across
      end
    end
  end
  if best then active = best.address end
end

hl = {
  get_active_window = function() return active and named(active) end,
  get_active_workspace = function() return workspace end,
  get_windows = function() return windows end,
  dsp = {
    focus = function(args) return { focus = args } end,
    window = { alter_zorder = function(args) return { zorder = args } end },
  },
  dispatch = function(dispatcher)
    local args = dispatcher.focus
    if not args then return end
    if args.direction then
      native_move(args.direction)
    else
      active = args.window:gsub("^address:", "")
    end
  end,
}

o = { bind_expressions = {} }

local focus = require("default.hypr.window-focus")
local failures = 0

local function check(condition, message)
  print((condition and "ok - " or "not ok - ") .. message)
  if not condition then failures = failures + 1 end
end

local function press(from, direction)
  active = from
  focus.direction(direction)()
  return active
end

-- Three tiles with a popped-out window centred over them.
window("chromium", 0, 0, 940, 570)
window("foot-right", 960, 0, 940, 1150)
window("foot-bottom", 0, 590, 940, 570)
window("popped", 310, 160, 1300, 900, true, true)

check(press("chromium", "r") == "popped", "a tile reaches the popped-out window to its right")
check(press("foot-right", "l") == "popped", "a tile reaches the popped-out window to its left")
check(press("chromium", "d") == "foot-bottom", "tile to tile still follows Hyprland's own move")
check(press("popped", "l") == "foot-bottom", "the popped-out window returns to the nearest tile on its left")
check(press("popped", "r") == "foot-right", "the popped-out window returns to the tile on its right")

-- A lone tile with a popped-out window sharing its centre: no direction separates them.
windows = {}
window("tile", 0, 0, 1900, 1150)
window("popped", 300, 125, 1300, 900, true, true)

check(press("tile", "r") == "popped", "a lone tile reaches the popped-out window centred on it")
check(press("popped", "l") == "tile", "a popped-out window centred on a lone tile returns to it")

check(o.bind_expressions[focus.direction("l")] == 'o.window_focus.direction("l")', "the keybindings menu can replay the bind")

os.exit(failures == 0 and 0 or 1)
LUA

if ROOT="$ROOT" lua "$tmpdir/test.lua"; then
  pass "SUPER + arrows reach floating windows and leave them"
else
  fail "SUPER + arrows reach floating windows and leave them"
fi
