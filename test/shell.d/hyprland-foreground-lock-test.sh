#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

OMARCHY_PATH="$ROOT" lua - <<'LUA' || fail "a fullscreen game stays behind when left, across config reloads"
local handlers, dispatched = {}, {}
local game = { address = "0xgame", pid = 1, mapped = true, xwayland = true, fullscreen = 2, tags = {} }
local browser = { address = "0xbrowser", pid = 2, mapped = true, tags = {} }
local windows = { [game.address] = game, [browser.address] = browser }
local active = game

-- Hyprland keeps a window's tags on the window, so they outlive a reload.
local function tag(window, change)
  local name = change:sub(2)
  for i = #window.tags, 1, -1 do
    if window.tags[i] == name then
      table.remove(window.tags, i)
    end
  end
  if change:sub(1, 1) == "+" then
    table.insert(window.tags, name)
  end
end

hl = {
  on = function(event, callback) handlers[event] = callback end,
  get_active_window = function() return active end,
  get_window = function(selector) return windows[(selector:gsub("^address:", ""))] end,
  dispatch = function(dispatcher)
    if dispatcher.tag then
      tag(dispatcher.window, dispatcher.tag)
    else
      table.insert(dispatched, dispatcher)
    end
  end,
  dsp = { window = { set_prop = function(args) return args end, tag = function(args) return args end } },
}

-- A config reload starts the file over with no handlers of its own yet.
local function load()
  handlers = {}
  package.loaded["default.hypr.foreground-lock"] = nil
  require("default.hypr.foreground-lock")
end

dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")
load()

active = browser
handlers["window.active"](browser)
assert(#dispatched == 1 and dispatched[1].window == game and dispatched[1].value == "0", "the game focused at reload stops taking focus back")

load()
active = game
handlers["window.active"](game)
assert(#dispatched == 2 and dispatched[2].window == game and dispatched[2].value == "unset", "the game the user brings back after a reload may take focus again")
assert(#game.tags == 0, "the game brought back is no longer locked")
LUA
pass "a fullscreen game stays behind when left, across config reloads"
