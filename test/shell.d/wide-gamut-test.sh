#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

# Runs the wrapper with fake monitors and EDIDs and checks the cm each rule gets.
OMARCHY_PATH="$ROOT" lua - <<'LUA' || fail "wide-gamut picks the color mapping for each monitor rule"
local script = os.getenv("OMARCHY_PATH") .. "/default/hypr/wide-gamut.lua"

package.loaded["default.hypr.paths"] = { omarchy_path = "/omarchy" }
o = {
  shell_succeeds = function() return true end,
  shell_quote = function(value) return value end,
}

-- An EDID whose chromaticity block holds the DCI-P3 primaries, or none at all.
local function edid(primaries)
  local bytes = {}
  for i = 1, 128 do bytes[i] = 0 end
  if primaries then
    local function ten(x) return math.floor(x * 1024 + 0.5) end
    local rx, ry, gx, gy, bx, by = ten(0.680), ten(0.320), ten(0.265), ten(0.690), ten(0.150), ten(0.060)
    bytes[26] = (rx % 4) << 6 | (ry % 4) << 4 | (gx % 4) << 2 | (gy % 4)
    bytes[27] = (bx % 4) << 6 | (by % 4) << 4
    bytes[28], bytes[29], bytes[30], bytes[31], bytes[32], bytes[33] =
      rx >> 2, ry >> 2, gx >> 2, gy >> 2, bx >> 2, by >> 2
  end
  return string.char(table.unpack(bytes))
end

local with_gamut, without_gamut = edid(true), edid(false)

-- monitors: { {name, description, edid}, ... }; rule: the table passed to hl.monitor.
local function cm_for(monitors, rule)
  local by_name, list, seen = {}, {}, nil
  for _, m in ipairs(monitors) do
    by_name[m[1]] = m[3]
    list[#list + 1] = { name = m[1], description = m[2] }
  end

  io.popen = function(command)
    local name = command:match("card%*%-([%w%-]+)/edid")
    return { read = function() return by_name[name] or "" end, close = function() end }
  end
  hl = {
    get_monitors = function() return list end,
    monitor = function(r) seen = r end,
  }

  dofile(script)
  hl.monitor(rule)
  return seen.cm
end

local function expect(got, want, what)
  assert(got == want, what .. ": got " .. tostring(got) .. ", want " .. tostring(want))
end

local panel = { "eDP-2", "Built-in", with_gamut }
local panel_blank = { "eDP-2", "Built-in", without_gamut }
local external = { "DP-1", "Studio Display", with_gamut }
local external_blank = { "DP-1", "Other", without_gamut }

expect(cm_for({ panel }, { output = "eDP-2" }), "edid", "panel with primaries")
expect(cm_for({ panel_blank }, { output = "eDP-2" }), "dp3", "built-in panel without primaries")
expect(cm_for({ external_blank }, { output = "DP-1" }), nil, "external monitor without primaries")
expect(cm_for({ panel, external }, { output = "" }), "edid", "all monitors with primaries")
expect(cm_for({ panel_blank, external }, { output = "" }), nil, "a rule shared by a blank panel and an external monitor")
expect(cm_for({ panel_blank, external }, { output = "eDP-2" }), "dp3", "the rule for the panel alone")
expect(cm_for({ panel_blank }, { output = "eDP-2", cm = "srgb" }), "srgb", "a cm in the rule is kept")
LUA
pass "wide-gamut maps a built-in panel without primaries to dp3, never to a black screen"
