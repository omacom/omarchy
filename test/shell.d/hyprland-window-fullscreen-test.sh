#!/bin/bash

# SUPER + F fullscreens a popped-out (SUPER + O) window: Hyprland refuses to
# fullscreen a pinned one, so it is unpinned and re-tiled first.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

cat >"$tmpdir/test.lua" <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path

local active, calls = nil, {}
local function record(name) return function(args) return { name = name, args = args } end end

hl = {
  get_active_window = function() return active end,
  dsp = { window = { pin = record("pin"), float = record("float"), tag = record("tag"), fullscreen = record("fullscreen") } },
  dispatch = function(dispatcher) calls[#calls + 1] = dispatcher.name end,
}
o = { bind_expressions = {} }

local m = require("default.hypr.window-fullscreen")
local failures = 0
local function check(condition, message)
  print((condition and "ok - " or "not ok - ") .. message)
  if not condition then failures = failures + 1 end
end

active, calls = { address = "a", pinned = true, floating = true }, {}
m.toggle()()
check(table.concat(calls, ",") == "pin,float,tag,fullscreen", "a popped-out window is unpinned and re-tiled before fullscreen")

active, calls = { address = "b", pinned = false, floating = false }, {}
m.toggle()()
check(table.concat(calls, ",") == "fullscreen", "an ordinary window goes straight to fullscreen")

check(o.bind_expressions[m.toggle()] == "o.window_fullscreen.toggle()", "the keybindings menu can replay the bind")

os.exit(failures == 0 and 0 or 1)
LUA

if ROOT="$ROOT" lua "$tmpdir/test.lua"; then
  pass "SUPER + F fullscreens a popped-out window"
else
  fail "SUPER + F fullscreens a popped-out window"
fi
