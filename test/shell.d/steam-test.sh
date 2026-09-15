#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local rules = {}

hl = {
  window_rule = function(rule)
    table.insert(rules, rule)
  end,
}

require("default.hypr.helpers")
require("default.hypr.apps.steam")

local main_client_float_rule
local friends_float_rule
local steam_idle_rule
local gamescope_idle_rule
local unqualified_steam_float_rule

for _, rule in ipairs(rules) do
  local class = rule.match and rule.match.class
  local title = rule.match and rule.match.title

  if class == "steam" and title == "Steam" and rule.float == true then
    main_client_float_rule = rule
  end

  if class == "steam" and title == "Friends List" and rule.float == true then
    friends_float_rule = rule
  end

  if class == "steam" and title == nil and rule.float == true then
    unqualified_steam_float_rule = rule
  end

  if class == "steam.*" and rule.idle_inhibit == "fullscreen" then
    steam_idle_rule = rule
  end

  if class == "gamescope" and rule.idle_inhibit == "fullscreen" then
    gamescope_idle_rule = rule
  end
end

assert(main_client_float_rule, "Steam main window keeps its floating rule")
assert(friends_float_rule, "Steam friends window keeps its floating rule")
assert(not unqualified_steam_float_rule, "Steam games using class steam are not forced to float")
assert(steam_idle_rule, "Steam and steam_app windows inhibit idle while fullscreen")
assert(steam_idle_rule.float == nil, "Steam games are not forced to float")
assert(gamescope_idle_rule, "gamescope windows inhibit idle while fullscreen")
LUA

pass "fullscreen Steam and gamescope games inhibit idle without inheriting client layout rules"
