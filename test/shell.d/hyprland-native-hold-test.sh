#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command lua

OMARCHY_PATH="$ROOT" lua - "$ROOT/default/hypr/helpers.lua" <<'LUA'
-- Stock 0.56.2 press/release boundary model, not a compositor integration test.
local root, helper = assert(os.getenv("OMARCHY_PATH")), assert(arg[1])
local clock, timers, events, context, current, dragging = 0, {}, {}, -1, nil, false
local handles, subscriptions, wrappers, dispatchers = {}, {}, {}, {}
local function log(value) events[#events + 1] = value end
local function same(value) assert(table.concat(events, ",") == value, table.concat(events, ",")) end
local function dispatcher(fn)
  local value = assert(io.tmpfile()) -- noncallable native-like userdata
  dispatchers[value] = fn
  return value
end
local function native(name)
  return dispatcher(function()
    if current then current.release_pending = true end
    if context == 1 then dragging = true; log(name)
    else dragging = false; log("end") end
  end)
end
hl = {
  dsp = { window = { resize = function() return native("resize") end, drag = function() return native("move") end },
    exec_cmd = function(command) return dispatcher(function() log(command) end) end },
  dispatch = function(value)
    assert(type(value) == "userdata" and dispatchers[value], "native userdata must use hl.dispatch")
    dispatchers[value]()
  end,
  timer = function(fn, opts)
    assert(opts.type == "oneshot")
    local t = { fn = fn, due = clock + opts.timeout, enabled = true, retained = true }
    function t:set_enabled(value)
      self.enabled = value -- stock disarming does not unref the callback
    end
    timers[#timers + 1] = t
    return t
  end,
  on = function(name, fn)
    assert(name == "input.keyboard.key")
    local s = { fn = fn, active = true }
    function s:remove() self.active = false end
    subscriptions[#subscriptions + 1] = s
    return s
  end,
  bind = function(keys, fn, opts)
    assert(opts.double_press == nil and opts.timeout == nil and opts.hold_keycode == nil)
    local h = { keys = keys, callback = fn, options = opts, enabled = true }
    function h:is_enabled() assert(not self.removed); return self.enabled end
    function h:set_enabled(value) assert(not self.removed); self.enabled = value end
    function h:remove()
      assert(not self.removed)
      for _, other in ipairs(handles) do if other.keys == self.keys then other.removed = true end end
    end
    setmetatable(h, { __tostring = function(self) return self.removed and "HL.Keybind(expired)" or "HL.Keybind(live)" end })
    handles[#handles + 1] = h
    return h
  end,
  unbind = function(keys)
    for _, h in ipairs(handles) do if h.keys == keys then h.removed = true end end
  end,
}
local function advance(ms)
  local until_time = clock + ms
  while true do
    local next_timer
    for _, t in ipairs(timers) do
      if t.enabled and t.due <= until_time and (not next_timer or t.due < next_timer.due) then next_timer = t end
    end
    if not next_timer then break end
    clock = next_timer.due; next_timer.enabled = false; next_timer.fn(); next_timer.retained = false
  end
  clock = until_time
end
local function raw(state, code)
  for _, s in ipairs(subscriptions) do if s.active then s.fn(code or 64, clock, state) end end
end
local function event(h, pressed, main_release, companion_release)
  raw(pressed and 1 or 0)
  local hits = {}
  for _, candidate in ipairs(handles) do
    if candidate.keys == h.keys and not candidate.removed and candidate.enabled then
      local hit
      if candidate.options.release then
        hit = pressed and candidate.release_pending or (not pressed and companion_release ~= false)
      else
        hit = pressed or (candidate.release_pending and main_release ~= false)
      end
      if hit then hits[#hits + 1] = candidate end
    end
  end
  -- Deliberately don't model the normal engine's automatic end: release tests
  -- must prove the companion dispatch stops native mode in release context.
  for _, hit in ipairs(hits) do
    current, context = hit, pressed and 1 or 0
    hit.release_pending = false
    hit.callback()
    current, context = nil, -1
  end
  if not pressed and companion_release == false then dragging = false end -- native event still stops it
end
local function press(h) event(h, true) end
local function release(h, main) event(h, false, main) end
local function tap(h, main) press(h); release(h, main) end
package.preload["default.hypr.paths"] = function() return { omarchy_path = root } end
o = {}; dofile(helper)
local function pair(options)
  options = options or {}
  options.double_press, options.hold_keycode = { hold = "drag" }, 64
  local h = o.bind("SUPER + ALT_L", "test", { hold = "resize" }, options)
  wrappers[#wrappers + 1] = h
  return h
end
local function clean()
  for _, w in ipairs(wrappers) do w:remove() end
  advance(1000)
  for _, s in ipairs(subscriptions) do assert(not s.active, "managed cleanup removes observers") end
  for _, t in ipairs(timers) do assert(not t.retained, "canceled one-shot must fire for native callback cleanup") end
  handles, subscriptions, wrappers, timers, events, clock, dragging = {}, {}, {}, {}, {}, 0, false
end
assert(not pcall(function() hl.dsp.window.drag()() end))
local h = pair()
assert(o.bind_commands[h.callback] == nil, "interactive menu row cannot execute native single")
press(h); same("resize"); advance(250); same("resize")
release(h, false); same("resize,end"); assert(not dragging)
for _, main in ipairs({ false, true }) do
  clean(); h = pair()
  tap(h, main); advance(125); press(h)
  same("resize,end,move"); assert(dragging)
  advance(500); same("resize,end,move")
  release(h, main); same("resize,end,move,end"); assert(not dragging)
  events = {}; press(h); same("resize") -- companion's releasePending press re-entry must not end/start
  release(h, main); same("resize,end")
end
clean(); h = pair()
press(h); advance(1517); release(h, false); advance(2804)
press(h); advance(49); release(h, false); advance(76); press(h)
same("resize,end,resize,end,move"); release(h, false); assert(not dragging)
-- Suppressed companion must not swallow the next physical press.
clean(); h = pair(); press(h); event(h, false, false, false); advance(500)
press(h); same("resize,resize"); release(h, false)
for _, timeout in ipairs({ 250, 500 }) do
  clean(); h = pair({ timeout = timeout }); tap(h, false); advance(timeout - 1); press(h)
  same("resize,end,move")
  clean(); h = pair({ timeout = timeout }); tap(h, false); advance(timeout); press(h)
  same("resize,end,resize")
end
clean(); h = pair(); tap(h, false); tap(h, false); press(h)
same("resize,end,move,end,resize")
clean()
h = o.bind("SUPER + ALT_L", "mixed", "command-single", { double_press = { hold = "drag" }, hold_keycode = 64 })
wrappers[#wrappers + 1] = h
tap(h, false); advance(250); same("command-single")
events = {}; tap(h, false); press(h); same("move"); release(h, false)
clean()
h = o.bind("SUPER + ALT_L", "mixed", { hold = "resize" }, { double_press = "command-double", hold_keycode = 64 })
wrappers[#wrappers + 1] = h
tap(h, false); tap(h, false); same("resize,end"); advance(1); same("resize,end,command-double")
clean(); h = pair(); press(h)
-- Disable from a different key's pressed context must defer the stop.
context = 1; h:set_enabled(false); context = -1
same("resize"); advance(1); same("resize,end"); assert(not dragging and not h:is_enabled())
for _, s in ipairs(subscriptions) do assert(not s.active) end
h:set_enabled(true); press(h); same("resize,end,resize"); release(h, false)
for _, method in ipairs({ "remove", "unbind" }) do
  clean(); h = pair(); press(h); h[method](h)
  for _, s in ipairs(subscriptions) do assert(not s.active) end
  assert(tostring(h) == "HL.Keybind(expired)")
  local replacement = pair(); press(replacement); advance(1)
  same("resize,resize"); assert(dragging, "old scheduled stop cannot end new managed hold")
  h:remove(); h:set_enabled(false); assert(replacement:is_enabled())
  release(replacement, false); assert(not dragging)
end
clean(); h = pair(); tap(h, false)
local replacement = o.rebind("SUPER + ALT_L", "new", { hold = "resize" }, { double_press = { hold = "drag" }, hold_keycode = 64 })
wrappers[#wrappers + 1] = replacement
assert(not subscriptions[1].active, "rebind immediately removes old observer")
press(replacement); same("resize,end,resize"); release(replacement, false)
hl.unbind("SUPER + ALT_L"); raw(1, 90)
for _, s in ipairs(subscriptions) do assert(not s.active, "raw unbind cleans observer on next input") end
advance(500); assert(not replacement:is_enabled())
clean()
h = pair({ timeout = 5000 }); tap(h, false); press(h); release(h, false); h:remove()
advance(1)
local waiting = 0
for _, t in ipairs(timers) do
  if t.retained then waiting = waiting + 1; assert(t.enabled, "cancellation must not disarm native cleanup") end
end
assert(waiting == 1, "one logically canceled decision awaits native one-shot cleanup")
events = {}; advance(5000); same("")
for _, t in ipairs(timers) do assert(not t.retained, "one-shot callback released after canceled deadline") end
clean()
local guarded = o.bind("GUARDED", "guarded", function() end)
local invalids = {
  { { hold = "wrong" }, { double_press = "command", hold_keycode = 64 } },
  { { hold = "resize", launch = "bad" }, { double_press = "command", hold_keycode = 64 } },
  { { hold = "resize" }, {} },
  { { hold = "resize" }, { double_press = { hold = "drag" } } },
  { "command", { double_press = "double", hold_keycode = 64 } },
}
for _, code in ipairs({ 0, 7, 768, 64.5, "64" }) do
  invalids[#invalids + 1] = { { hold = "resize" }, { double_press = { hold = "drag" }, hold_keycode = code } }
end
for _, flag in ipairs({ "release", "click", "drag", "repeating", "long_press" }) do
  invalids[#invalids + 1] = { { hold = "resize" }, { double_press = "command", hold_keycode = 64, [flag] = true } }
end
for _, case in ipairs(invalids) do
  assert(not pcall(o.rebind, "GUARDED", "bad", case[1], case[2]))
  assert(not guarded.removed, "validate before unbind")
end
local on = hl.on; hl.on = nil
assert(not pcall(o.rebind, "GUARDED", "bad", { hold = "resize" }, { double_press = "command", hold_keycode = 64 }))
assert(not guarded.removed); hl.on = on
for value in pairs(dispatchers) do value:close() end
print("ok - stock hold actions cover native context, physical release, companion re-entry, timing, lifecycle and validation")
LUA

pass "stock native double-press hold behavior"
