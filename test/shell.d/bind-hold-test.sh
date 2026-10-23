#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

HOME="$(mktemp -d)" OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local binds, ran = {}, {}
hl = setmetatable({
  dsp = setmetatable({}, {
    __index = function(_, name)
      return function(arg) return { dsp = name, arg = arg } end
    end,
  }),
  bind = function(keys, dispatcher, opts)
    table.insert(binds, { keys = keys, dispatcher = dispatcher, opts = opts })
  end,
  exec_cmd = function(command) table.insert(ran, command) end,
  dispatch = function(dispatcher) table.insert(ran, dispatcher.dsp .. " " .. dispatcher.arg) end,
}, {
  __index = function()
    return function() return {} end
  end,
})

require("default.hypr.helpers")

local function ran_since(fn)
  local before = #ran
  fn()
  return table.concat({ table.unpack(ran, before + 1) }, "\n")
end

local options = { locked = true }
o.bind_hold("SUPER + X", "Start", "start-cmd", "Stop", "stop-cmd", options)
local press, release = binds[1], binds[2]
assert(press.keys == "SUPER + X" and release.keys == "SUPER + X", "both halves bind the same keys")
assert(press.opts.description == "Start" and release.opts.description == "Stop", "each half keeps its description")
assert(not press.opts.release and not press.opts.transparent, "the press half is an ordinary bind")
assert(release.opts.release and release.opts.transparent and release.opts.ignore_mods,
  "the release half survives keys typed and modifiers changed during the hold")
assert(release.opts.non_consuming, "the release half leaves the key to apps when its press did not run")
assert(press.opts.locked and release.opts.locked, "caller options apply to both halves")
assert(options.release == nil and options.description == nil, "caller options are not modified")
assert(o.bind_commands[press.dispatcher] == "start-cmd" and o.bind_commands[release.dispatcher] == "stop-cmd",
  "the keybindings menu can run each half")

assert(ran_since(release.dispatcher) == "", "a release without its press does nothing")
assert(ran_since(press.dispatcher) == "start-cmd", "the press runs its command")
assert(ran_since(release.dispatcher) == "stop-cmd", "the release ends what the press started")
assert(ran_since(release.dispatcher) == "", "a release runs once per press")

o.bind_hold("SUPER + R", "Start", "start-cmd", "Stop", "stop-cmd",
  { repeating = true, long_press = true, click = true, drag = true, locked = true })
local repeat_release, repeat_press = table.remove(binds), table.remove(binds)
assert(repeat_press.opts.repeating, "the press half keeps its options")
for _, key in ipairs({ "repeating", "long_press", "click", "drag" }) do
  assert(repeat_release.opts[key] == nil, "the release half drops " .. key)
end
assert(repeat_release.opts.locked, "the release half keeps other options")

o.bind_hold("SUPER + Z", "Start", hl.dsp.exec_cmd("start-dsp"), "Stop", function() table.insert(ran, "stop-fn") end)
assert(ran_since(binds[3].dispatcher) == "exec_cmd start-dsp", "dispatchers are dispatched")
assert(ran_since(binds[4].dispatcher) == "stop-fn", "functions are called")
assert(ran_since(binds[2].dispatcher) == "", "each hold binding tracks its own press")
LUA
pass "hold bindings pair each release with its press"
