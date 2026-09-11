#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

OMARCHY_PATH="$ROOT" lua <<'LUA' || fail "1Password window rules separate privacy from main-window geometry"
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local captured = {}
hl = {
  window_rule = function(rule)
    table.insert(captured, rule)
  end,
}

require("default.hypr.helpers")
require("default.hypr.apps.1password")

assert(#captured == 2)

local privacy = captured[1]
assert(type(privacy.match.class) == "string" and privacy.match.class ~= "")
assert(privacy.match.title == nil)
assert(privacy.no_screen_share == true)
assert(privacy.tag == nil)

local mainWindow = captured[2]
assert(mainWindow.match.class == nil)
assert(mainWindow.match.title == "^.+ — 1Password$")
assert(mainWindow.no_screen_share == nil)
assert(mainWindow.tag == "+floating-window")
LUA

pass "1Password window rules separate privacy from main-window geometry"
