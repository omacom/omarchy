#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

test_home=$(mktemp -d)
trap 'rm -rf "$test_home"' EXIT

# `lua -` rather than bare `lua`: Lua 5.5 exits 0 when a script piped to bare `lua` fails.
HOME="$test_home" OMARCHY_PATH="$ROOT" lua - <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local started = {}
hl = setmetatable({
  on = function(event, fn) if event == "hyprland.start" then table.insert(started, fn) end end,
  exec_cmd = function(command) table.insert(started, command) end,
}, {
  __index = function()
    return function() return {} end
  end,
})

require("default.hypr.helpers")

assert(o.launch("foot") == "uwsm-app -- foot", "a plain command runs under uwsm-app")
assert(o.launch("[workspace 2 silent] foot --app-id x") == "[workspace 2 silent] uwsm-app -- foot --app-id x",
  "exec rules stay in front of uwsm-app for Hyprland to apply")
assert(o.launch("  [float; size 800 600]   foot") == "[float; size 800 600] uwsm-app -- foot",
  "exec rules with several rules and extra spacing are kept whole")
assert(o.launch("[workspace 2 silent] foot -e 'echo [x]'") == "[workspace 2 silent] uwsm-app -- foot -e 'echo [x]'",
  "brackets after the rules stay in the command")
assert(o.launch("foot -e 'echo [x]'") == "uwsm-app -- foot -e 'echo [x]'",
  "brackets later in the command are left alone")

o.launch_on_start("[workspace 3 silent] foot")
local on_start = table.remove(started, 1)
on_start()
assert(started[1] == "[workspace 3 silent] uwsm-app -- foot", "launch_on_start keeps exec rules too")
LUA
pass "launching through uwsm-app keeps Hyprland exec rules"
