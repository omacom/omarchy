#!/bin/bash

# Per-monitor workspace ids. The mapping is pure Lua so it can run without Hyprland.

source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

set -euo pipefail

lua_bin=$(command -v lua5.4 || command -v lua || true)
[[ -n $lua_bin ]] || fail "lua is available"

"$lua_bin" - "$ROOT" <<'LUA' || fail "monitor workspace ids stay on their own display"
local root = arg[1]
local M = dofile(root .. "/default/hypr/monitor-workspaces.lua")

local function eq(actual, expected, label)
  if actual ~= expected then
    io.stderr:write(label .. ": expected " .. tostring(expected) .. " got " .. tostring(actual) .. "\n")
    os.exit(1)
  end
end

eq(M.global_id(0, 1), 1, "internal workspace 1")
eq(M.global_id(0, 10), 10, "internal workspace 10")
eq(M.global_id(1, 1), 11, "second monitor workspace 1")
eq(M.global_id(1, 6), 16, "second monitor workspace 6")
eq(M.local_number(0, 6), 6, "6 on the internal display")
eq(M.local_number(0, 11), nil, "11 is not on the internal display")
eq(M.local_number(1, 16), 6, "16 is workspace 6 on the second display")

local laptop = "Apple Computer Inc Color LCD"
local external = "LG Electronics LG ULTRAGEAR"
local slots = M.assign_slots({
  { name = "HDMI-A-2", description = external, position = { x = 1280, y = 0 } },
  { name = "eDP-1", description = laptop, position = { x = 0, y = 0 } },
}, {})
eq(slots[laptop], 0, "internal panel keeps workspace ids 1-10")
eq(slots[external], 1, "external display gets the next block")

local again = M.assign_slots({
  { name = "HDMI-A-1", description = external, position = { x = 0, y = 0 } },
  { name = "eDP-1", description = laptop, position = { x = 1280, y = 0 } },
}, slots)
eq(again[laptop], 0, "replug keeps the internal slot")
eq(again[external], 1, "replug keeps the external slot")

local moves = M.plan_moves({
  { id = 1, description = laptop },
  { id = 2, description = laptop },
  { id = 4, description = laptop },
  { id = 5, description = laptop },
  { id = 6, description = external },
  { id = 7, description = external },
  { id = -99, description = laptop, special = true },
}, slots)
eq(#moves, 2, "only the external display's out-of-range workspaces move")
eq(moves[1].from, 6, "workspace 6 moves")
eq(moves[1].to, 16, "workspace 6 stays workspace 6 on that display")
eq(moves[2].from, 7, "workspace 7 moves")
eq(moves[2].to, 17, "workspace 7 stays workspace 7 on that display")

local swap = M.plan_moves({
  { id = 16, description = laptop },
  { id = 6, description = external },
}, { [laptop] = 0, [external] = 1 })
eq(#swap, 4, "a swap parks both workspaces before they take each other's ids")
eq(swap[1].to, M.park_base + 1, "first park id")
eq(swap[3].from, M.park_base + 1, "parked workspace moves to its final id")

local occupied = M.plan_moves({
  { id = 6, description = external },
  { id = 16, description = external },
}, { [external] = 1 })
eq(#occupied, 1, "an occupied target picks another free slot on that display")
eq(occupied[1].from, 6, "the out-of-range workspace is the one that moves")
eq(occupied[1].to == 16, false, "does not steal a workspace already on that display")
eq(M.local_number(1, occupied[1].to) ~= nil, true, "the free slot is still on that display")
LUA

pass "monitor workspace ids stay on their own display"
