#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

# uwsm owns the session PATH (default/bash/env-bootstrap via 10-omarchy), so
# Hyprland must not reorder it: a prepend here puts $OMARCHY_PATH/bin ahead of
# every user directory for keybinds, and autostart imports it into systemd.
HOME="/home/test-user" OMARCHY_PATH="$ROOT" lua - <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
local set = {}
hl = setmetatable({ env = function(name, value) set[name] = value end }, { __index = function() return function() end end })
o = { shell_succeeds = function() return false end, shell_quote = function(value) return value end }
require("default.hypr.envs")
assert(set.OMARCHY_PATH == os.getenv("OMARCHY_PATH"), "OMARCHY_PATH: " .. tostring(set.OMARCHY_PATH))
assert(set.PATH == nil, "envs.lua sets PATH: " .. tostring(set.PATH))
LUA
pass "Hyprland envs leave the session PATH to uwsm"
