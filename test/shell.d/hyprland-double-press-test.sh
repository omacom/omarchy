#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

OMARCHY_PATH="$ROOT" lua - <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local events = {}
local converted_commands = {}
local handles = {}
local timers = {}
local clock = 0
local unbind_count = 0
local current_keybind

local function expect(condition, message)
  if not condition then
    error(message, 2)
  end
end

local function events_as_text()
  return table.concat(events, "|")
end

local function expect_events(wanted, message)
  local expected = table.concat(wanted, "|")
  expect(events_as_text() == expected,
    string.format("%s (expected %q, got %q)", message, expected, events_as_text()))
end

local function clear_events()
  events = {}
end

local function reset_clock()
  expect(#timers == 0, "test left an unprocessed timer")
  clock = 0
  clear_events()
end

local function next_due_timer(target)
  local selected_index
  local selected

  for index, timer in ipairs(timers) do
    if timer.due <= target and (not selected or timer.due < selected.due or
        (timer.due == selected.due and timer.order < selected.order)) then
      selected_index = index
      selected = timer
    end
  end

  return selected_index, selected
end

local function advance(milliseconds)
  local target = clock + milliseconds

  while true do
    local index, timer = next_due_timer(target)
    if not timer then
      break
    end

    table.remove(timers, index)
    clock = timer.due
    timer.callback()
  end

  clock = target
end

local function mark(label)
  return function()
    table.insert(events, label)
  end
end

local function contains(values, wanted)
  for _, value in ipairs(values) do
    if value == wanted then
      return true
    end
  end

  return false
end

local function dispatcher(name)
  return { kind = "dispatcher", name = name }
end

hl = {
  dsp = {
    exec_cmd = function(command)
      table.insert(converted_commands, command)
      return { kind = "exec", command = command }
    end,
    global = function(name)
      return { kind = "global", name = name }
    end,
    window = {
      close = function() return dispatcher("window.close") end,
      fullscreen = function() return dispatcher("window.fullscreen") end,
    },
  },
  bind = function(keys, callback, options)
    local handle = {
      keys = keys,
      callback = callback,
      options = options or {},
      state = true,
    }

    setmetatable(handle, {
      __tostring = function(value)
        if value.state == "expired" then
          return "HL.Keybind(expired)"
        end

        return "HL.Keybind(" .. value.keys .. ")"
      end,
    })

    function handle:is_enabled()
      if self.state == "expired" then
        error("native keybind userdata has expired", 2)
      end

      return self.state == true
    end

    function handle:remove()
      self.state = "expired"
      self.callback = nil
    end

    table.insert(handles, handle)
    return handle
  end,
  unbind = function(keys)
    unbind_count = unbind_count + 1
    for _, handle in ipairs(handles) do
      if handle.keys == keys and handle.state ~= "expired" then
        handle.state = "expired"
      end
    end
  end,
  timer = function(callback, options)
    expect(options.type == "oneshot", "double press uses one-shot timers")
    local timer = {
      callback = callback,
      due = clock + options.timeout,
      order = #timers + 1,
      timeout = options.timeout,
    }
    table.insert(timers, timer)
    return timer
  end,
  dispatch = function(action)
    expect(type(action) == "table", "native dispatchers are passed to hl.dispatch")
    if action.kind == "exec" then
      table.insert(events, "dispatch:exec:" .. action.command)
    elseif action.kind == "global" then
      if current_keybind then
        current_keybind.release_pending = true
      end
      table.insert(events, "global:" .. action.name)
    elseif action.kind == "dispatcher" then
      table.insert(events, "dispatch:" .. action.name)
    else
      error("unknown fake dispatcher kind: " .. tostring(action.kind), 2)
    end
  end,
}

dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/helpers.lua")

local function press(handle)
  expect(handle.state == true, "test pressed a disabled or expired handle")
  current_keybind = handle
  handle.release_pending = false
  if type(handle.callback) == "function" then
    handle.callback()
  else
    hl.dispatch(handle.callback)
  end
  current_keybind = nil
end

local function release(handle)
  if handle.release_pending then
    press(handle)
  end
end

local function exercise_pair(key, description, single, double, expected_single, expected_double, options)
  local binding_options = { double_press = double }
  for option, value in pairs(options or {}) do
    binding_options[option] = value
  end
  local handle = o.bind(key, description, single, binding_options)

  reset_clock()
  press(handle)
  expect(#timers == 1, key .. " queues one pending timer")
  expect(timers[1].timeout == (options and options.timeout or 250), key .. " uses the expected timeout")
  advance(timers[1].timeout)
  expect_events({ expected_single }, key .. " runs the single action after the timeout")

  reset_clock()
  press(handle)
  press(handle)
  expect_events({}, key .. " defers the double action outside the key event")
  advance(1)
  expect_events({ expected_double }, key .. " runs only the double action inside the timeout")
  advance((options and options.timeout or 250))
  expect_events({ expected_double }, key .. " cancels the pending single action on a double press")

  return handle
end

local function_single = exercise_pair(
  "FUNCTION",
  "Function double press",
  mark("function-single"),
  mark("function-double"),
  "function-single",
  "function-double",
  { timeout = 60 }
)
expect(function_single.options.timeout == nil and function_single.options.double_press == nil,
  "native options omit double_press and timeout")

exercise_pair(
  "DEFAULT_TIMEOUT",
  "Default timeout double press",
  mark("default-single"),
  mark("default-double"),
  "default-single",
  "default-double"
)

local string_handle = exercise_pair(
  "STRING",
  "String double press",
  "string-single",
  "string-double",
  "dispatch:exec:string-single",
  "dispatch:exec:string-double",
  { timeout = 60 }
)
expect(contains(converted_commands, "string-single"), "single string commands convert through hl.dsp.exec_cmd")
expect(contains(converted_commands, "string-double"), "double string commands convert through hl.dsp.exec_cmd")
expect(string_handle.options.timeout == nil, "string binding does not forward timeout to native Hyprland")

exercise_pair(
  "DISPATCHER",
  "Dispatcher double press",
  hl.dsp.window.close(),
  hl.dsp.window.fullscreen(),
  "dispatch:window.close",
  "dispatch:window.fullscreen",
  { timeout = 60 }
)

exercise_pair(
  "LAUNCH_HELPERS",
  "Launch helper double press",
  { launch = "kitty --hold" },
  { webapp = "https://example.test" },
  "dispatch:exec:uwsm-app -- kitty --hold",
  "dispatch:exec:omarchy-launch-webapp 'https://example.test'",
  { timeout = 60 }
)
expect(contains(converted_commands, "uwsm-app -- kitty --hold"),
  "single launch helper tables convert to launch commands")
expect(contains(converted_commands, "omarchy-launch-webapp 'https://example.test'"),
  "double launch helper tables convert to launch commands")

local native_options = {
  double_press = "options-double",
  timeout = 90,
  locked = true,
  marker = "forwarded",
}
local options_handle = o.bind("OPTIONS", "Timed options", "options-single", native_options)
expect(native_options.double_press == "options-double" and native_options.timeout == 90,
  "caller options remain unchanged")
expect(native_options.description == nil, "caller options do not receive the bind description")
expect(options_handle.options.locked == true and options_handle.options.marker == "forwarded",
  "native options are forwarded")
expect(options_handle.options.description == "Timed options",
  "bind description is forwarded to native Hyprland")
expect(options_handle.options.double_press == nil and options_handle.options.timeout == nil,
  "timing options are removed from native options")

reset_clock()
press(options_handle)
advance(89)
press(options_handle)
advance(1)
expect_events({ "dispatch:exec:options-double" }, "a press just inside the timeout is a double press")
advance(1)
expect_events({ "dispatch:exec:options-double" }, "the canceled timer does not run at the timeout")

reset_clock()
press(options_handle)
advance(90)
expect_events({ "dispatch:exec:options-single" }, "the first press runs at the timeout boundary")
press(options_handle)
expect_events({ "dispatch:exec:options-single" }, "a second press at the boundary starts a new single press")
advance(90)
expect_events({ "dispatch:exec:options-single", "dispatch:exec:options-single" },
  "a late second press gets its own single timer")

local independent_a = o.bind("INDEPENDENT_A", "Independent A", mark("a-single"), {
  double_press = mark("a-double"),
  timeout = 40,
})
local independent_b = o.bind("INDEPENDENT_B", "Independent B", mark("b-single"), {
  double_press = mark("b-double"),
  timeout = 40,
})
reset_clock()
press(independent_a)
press(independent_b)
press(independent_b)
advance(1)
expect_events({ "b-double" }, "independent bindings keep separate pending presses")
advance(40)
expect_events({ "b-double", "a-single" }, "one binding can single-fire while another double-fires")

local triple = o.bind("TRIPLE", "Triple press", mark("triple-single"), {
  double_press = mark("triple-double"),
  timeout = 40,
})
reset_clock()
press(triple)
advance(10)
press(triple)
advance(1)
advance(10)
press(triple)
advance(20)
expect_events({ "triple-double" },
  "a stale first timer does not steal the third press before its own timeout")
advance(20)
expect_events({ "triple-double", "triple-single" },
  "a triple press leaves the third press as a fresh single without stale timer theft")

local plain = o.bind("PLAIN", "Plain binding", "plain-command", { locked = true })
reset_clock()
press(plain)
expect_events({ "dispatch:exec:plain-command" }, "non-timed bindings remain immediate")
expect(#timers == 0, "non-timed bindings do not create timers")
expect(plain.options.locked == true, "non-timed native options remain intact")

local disabled = o.bind("DISABLED", "Disabled pending", mark("disabled-single"), {
  double_press = mark("disabled-double"),
  timeout = 30,
})
reset_clock()
press(disabled)
disabled.state = false
advance(30)
expect_events({}, "a disabled handle skips its pending single action")

local removed = o.bind("REMOVED", "Removed pending", mark("removed-single"), {
  double_press = mark("removed-double"),
  timeout = 30,
})
reset_clock()
press(removed)
hl.unbind("REMOVED")
expect(tostring(removed) == "HL.Keybind(expired)", "unbound handles expose the expired native identity")
advance(30)
expect_events({}, "an expired handle skips its pending action without querying is_enabled")

local old_binding = o.bind("REBIND", "Old binding", mark("old-single"), {
  double_press = mark("old-double"),
  timeout = 30,
})
reset_clock()
press(old_binding)
local new_binding = o.rebind("REBIND", "New binding", mark("new-single"), {
  double_press = mark("new-double"),
  timeout = 30,
})
expect(tostring(old_binding) == "HL.Keybind(expired)", "rebind expires the old native handle")
press(new_binding)
advance(30)
expect_events({ "new-single" }, "rebind skips old pending work and runs the new binding")

local guarded = o.bind("GUARDED", "Guarded binding", mark("guarded"), { locked = true })
local unbinds_before_rejection = unbind_count
local function expect_rejected(label, options)
  local accepted = pcall(function()
    o.rebind("GUARDED", "Rejected binding", mark("replacement"), options)
  end)
  expect(not accepted, label .. " is rejected")
  expect(unbind_count == unbinds_before_rejection, label .. " is rejected before unbinding")
  expect(guarded.state == true, label .. " leaves the existing binding enabled")
end

expect_rejected("repeating with double_press", { double_press = "second", repeating = true })
expect_rejected("long_press with double_press", { double_press = "second", long_press = true })
expect_rejected("zero timeout", { double_press = "second", timeout = 0 })
expect_rejected("fractional timeout", { double_press = "second", timeout = 1.5 })
expect_rejected("text timeout", { double_press = "second", timeout = "250" })

local shell_helper = o.bind("SHELL_HELPER", "Shell shortcut double press", { ipc = "notifications.showHistory" }, {
  double_press = { ipc = "notifications.dismissAll" },
})
reset_clock()
press(shell_helper)
release(shell_helper)
press(shell_helper)
release(shell_helper)
expect_events({}, "shell double action waits until outside the key event")
advance(1)
expect_events({ "global:omarchy:ipc.notifications.dismissAll" }, "shell double action dispatches once")
release(shell_helper)
advance(250)
expect_events({ "global:omarchy:ipc.notifications.dismissAll" }, "key release does not re-arm a single action")

for _, remove in ipairs({ false, true }) do
  local handle = o.bind("DOUBLE_LIFETIME", "Pending double", mark("single"), { double_press = mark("double") })
  reset_clock()
  press(handle)
  press(handle)
  if remove then
    handle:remove()
  else
    handle.state = false
  end
  advance(250)
  expect_events({}, "disabled or removed binding skips its deferred double action")
end

local function command_count()
  local count = 0
  for _ in pairs(o.bind_commands) do
    count = count + 1
  end
  return count
end

collectgarbage("collect")
local commands_before = command_count()
local replacement
for _ = 1, 1000 do
  if replacement then
    replacement:remove()
  end
  replacement = o.rebind("COLLECTION", "Replaced binding", "single", { double_press = "double" })
end
collectgarbage("collect")
expect(command_count() == commands_before + 1,
  "only the live replacement keeps its menu metadata after collection")
local live = handles[#handles]
expect(o.bind_commands[live.callback] ~= nil, "live callback metadata survives collection")
reset_clock()
press(live)
advance(250)
expect_events({ "dispatch:exec:single" }, "the live replacement still works after collection")
live:remove()
collectgarbage("collect")
expect(command_count() == commands_before, "removing the native callback releases its menu metadata entry")

print("ok - double press bindings cover timing, action conversion, lifetime, collection, and validation")
LUA

pass "double press binding behavior"
