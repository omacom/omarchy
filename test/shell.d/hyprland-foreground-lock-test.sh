#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

OMARCHY_PATH="$ROOT" lua - <<'LUA' || fail "a fullscreen game focused across a config reload stays behind when left"
local handlers, locked = {}, {}
local game = { address = "0xgame", pid = 1, mapped = true, xwayland = true, fullscreen = 2 }

hl = {
  on = function(event, callback) handlers[event] = callback end,
  get_active_window = function() return game end,
  get_window = function(selector) return selector == "address:" .. game.address and game or nil end,
  dispatch = function(dispatcher) table.insert(locked, dispatcher) end,
  dsp = { window = { set_prop = function(args) return args end } },
}

dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")
require("default.hypr.foreground-lock")

handlers["window.active"]({ address = "0xbrowser", pid = 2, mapped = true })
assert(#locked == 1 and locked[1].window == game and locked[1].value == "0", "the game focused at reload stops taking focus back")
LUA
pass "a fullscreen game focused across a config reload stays behind when left"
