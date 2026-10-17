#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

now=$(date +%s)
OMARCHY_LAUNCH_WORKSPACE=3 OMARCHY_LAUNCH_TIME=$now sleep 30 &
fresh=$!
OMARCHY_LAUNCH_WORKSPACE="special:scratchpad" OMARCHY_LAUNCH_TIME=$now sleep 30 &
special=$!
OMARCHY_LAUNCH_WORKSPACE=3 OMARCHY_LAUNCH_TIME=$((now - 91)) sleep 30 &
expired=$!
sleep 30 &
unstamped=$!
trap 'kill $fresh $special $expired $unstamped 2>/dev/null' EXIT

FRESH=$fresh SPECIAL=$special EXPIRED=$expired UNSTAMPED=$unstamped \
  HOME="$(mktemp -d)" OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local binds, ran, handlers, timers = {}, {}, {}, {}
local active, active_special = { name = "2" }, nil

hl = setmetatable({
  dsp = {
    exec_cmd = function(command) return { kind = "exec", arg = command } end,
    window = {
      move = function(args) return { kind = "move", args = args } end,
      set_prop = function(args) return { kind = "set_prop", args = args } end,
    },
  },
  bind = function(keys, dispatcher) binds[keys] = dispatcher end,
  exec_cmd = function(command) table.insert(ran, command) end,
  dispatch = function(dispatcher) table.insert(ran, dispatcher) end,
  on = function(event, handler) handlers[event] = handler end,
  timer = function(fn, opts) table.insert(timers, { fn = fn, opts = opts }) end,
  get_active_workspace = function() return active end,
  get_active_special_workspace = function() return active_special end,
}, {
  __index = function()
    return function() return {} end
  end,
})

require("default.hypr.helpers")
require("default.hypr.launch-workspace")

local function run(fn)
  ran = {}
  fn()
  return ran
end

-- Binds stamp the workspace focused when the key is pressed, not when bound.
o.bind("SUPER + B", "Browser", { launch = "chromium" })
active = { name = "4" }
local command = run(binds["SUPER + B"])[1]
assert(command:find("^export OMARCHY_LAUNCH_WORKSPACE='4' OMARCHY_LAUNCH_TIME=%d+; uwsm%-app %-%- chromium$"),
  "a bind launch carries the workspace focused at press time: " .. command)
assert(o.bind_commands[binds["SUPER + B"]] == "uwsm-app -- chromium", "the keybindings menu still sees the plain command")

active_special = { name = "special:scratchpad" }
assert(run(binds["SUPER + B"])[1]:find("OMARCHY_LAUNCH_WORKSPACE='special:scratchpad'", 1, true),
  "a launch from an open special workspace returns there")
active_special = nil

local open = handlers["window.open"]
local function open_window(pid, workspace)
  timers = {}
  return run(function() open({ pid = tonumber(pid), workspace = { name = workspace } }) end)
end

local moved = open_window(os.getenv("FRESH"), "1")
assert(moved[1].kind == "move" and moved[1].args.workspace == "3" and moved[1].args.follow == false,
  "a window from a fresh launch moves to its launch workspace without following it")
assert(moved[2].kind == "set_prop" and moved[2].args.prop == "focus_on_activate" and moved[2].args.value == "0",
  "the moved window can't pull focus back while it starts")
assert(#timers == 1 and timers[1].opts.timeout > 0 and timers[1].opts.timeout <= 90000,
  "focus_on_activate comes back when the launch window ends")
local restored = run(timers[1].fn)
assert(restored[1].args.value == "unset", "the restored window follows the global focus_on_activate again")

assert(open_window(os.getenv("SPECIAL"), "1")[1].args.workspace == "special:scratchpad",
  "a special workspace is addressed by its name")
assert(#open_window(os.getenv("FRESH"), "3") == 0, "a window already on its launch workspace stays put")
assert(#open_window(os.getenv("EXPIRED"), "1") == 0, "windows opened after the launch window open where you are")
assert(#open_window(os.getenv("UNSTAMPED"), "1") == 0, "windows from unstamped processes, like portal dialogs, open where you are")
LUA
pass "launches open on the workspace they were started from"
