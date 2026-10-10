#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

# The helpers read HOME, so give them one the test owns and cleans up.
tmpdir=$(mktemp -d) && [[ -n $tmpdir && -d $tmpdir ]] ||
  fail "the test gets a temporary directory to load the bindings in"
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/home"

# Drive o.describe_key() from default/hypr/bindings/utilities.lua against a stub
# hl that plays key events into it, and print what it does, one line per call:
# the commands it runs, the submaps it enters, and whether it is still listening
# for keys or holding a timer. A scenario names the keys held before it starts,
# then the events: "+code" presses, "-code" releases, "escape" presses ESCAPE in
# the submap, "timeout" fires the timer.
describe_trace() {
  HOME="$tmpdir/home" OMARCHY_PATH="$ROOT" lua - "$@" <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local held, listeners, timers, submaps, current = {}, {}, {}, {}, nil

local function proxy()
  return setmetatable({}, {
    __index = function(self, key)
      local value = proxy()
      rawset(self, key, value)
      return value
    end,
    __call = function()
      return {}
    end,
  })
end

local dsp = proxy()
rawset(dsp, "submap", function(name) return { submap = name } end)
rawset(dsp, "exec_cmd", function(command) return { exec = command } end)

hl = setmetatable({
  dsp = dsp,
  bind = function(keys, dispatcher)
    if current then submaps[current][keys] = dispatcher end
    return {}
  end,
  define_submap = function(name, fn)
    submaps[name], current = {}, name
    fn()
    current = nil
  end,
  on = function(event, callback)
    local listener = { event = event, callback = callback, active = true }
    table.insert(listeners, listener)
    if event ~= "input.keyboard.key" then return { remove = function() listener.active = false end } end
    print("listen " .. event)
    return { remove = function() if listener.active then listener.active = false print("stop listening") end end }
  end,
  timer = function(callback, opts)
    local timer = { callback = callback, enabled = true }
    table.insert(timers, timer)
    print("timer " .. opts.timeout .. " " .. opts.type)
    return { set_enabled = function(_, enabled) if timer.enabled and not enabled then print("timer off") end timer.enabled = enabled end }
  end,
  dispatch = function(dispatcher)
    if type(dispatcher) == "table" and dispatcher.submap then print("submap " .. dispatcher.submap) end
  end,
  exec_cmd = function(command) print("exec " .. command) end,
  is_key_down = function(code) return held[code] == true end,
}, {
  __index = function()
    return function() return {} end
  end,
})

require("default.hypr.helpers")
dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bindings/utilities.lua")

for code in (arg[1] or ""):gmatch("%d+") do held[tonumber(code)] = true end

print("start")
o.describe_key()

for index = 2, #arg do
  local event = arg[index]
  print("event " .. event)
  if event == "escape" then
    submaps["describe-key"]["ESCAPE"]()
  elseif event == "timeout" then
    for _, timer in ipairs(timers) do
      if timer.enabled then timer.callback() end
    end
  else
    local code = tonumber(event:sub(2))
    local state = event:sub(1, 1) == "+" and 1 or 0
    held[code] = state == 1 or nil
    for _, listener in ipairs(listeners) do
      if listener.active and listener.event == "input.keyboard.key" then listener.callback(code, false, state) end
    end
  end
end

local listening = false
for _, listener in ipairs(listeners) do
  listening = listening or (listener.active and listener.event == "input.keyboard.key")
end
print("listening " .. tostring(listening))
LUA
}

# Everything after the last event, so a check reads what the mode did then.
after() {
  sed -n "/^event $1\$/,\$p" <<<"$2"
}

# Starting puts Hyprland in the submap, prompts, listens for keys, and arms a
# timer so the submap can never keep swallowing keys.
trace=$(describe_trace "" +133 +65 -65)
grep -qx "exec omarchy-menu-keybindings --describe" <<<"$trace" ||
  fail "describe mode prompts for a chord" "$trace"
grep -qx "submap describe-key" <<<"$trace" ||
  fail "describe mode enters the describe-key submap" "$trace"
grep -qx "listen input.keyboard.key" <<<"$trace" && grep -qx "timer 10000 oneshot" <<<"$trace" ||
  fail "describe mode listens for keys and arms its timeout" "$trace"
pass "describe mode enters its submap, listens, and arms a timeout"

# Super, then Space: the chord is done when Space is released, and comes out in
# the order it was pressed.
done_trace=$(after -65 "$trace")
grep -qx "exec omarchy-menu-keybindings --describe 133 65" <<<"$done_trace" ||
  fail "a chord is described when its first key is released" "$trace"
grep -qx "submap reset" <<<"$done_trace" && grep -qx "stop listening" <<<"$done_trace" && grep -qx "timer off" <<<"$done_trace" ||
  fail "describing a chord leaves the submap, stops listening, and disarms the timer" "$trace"
grep -qx "listening false" <<<"$trace" ||
  fail "nothing is left listening once a chord is described" "$trace"
pass "a chord is described when its first key is released, and the mode ends"

# Pressing more keys before releasing any adds them to the chord.
trace=$(describe_trace "" +133 +50 +45 -45)
grep -qx "exec omarchy-menu-keybindings --describe 133 50 45" <<<"$trace" ||
  fail "every key pressed before the first release is part of the chord" "$trace"
pass "every key pressed before the first release is part of the chord"

# A key held since before the mode began (Shift from typing ?) was never seen
# pressed, so letting it go does not end the chord.
trace=$(describe_trace "50" -50 +36 -36)
! grep -q "^exec omarchy-menu-keybindings --describe [0-9]" <<<"$(sed -n '/^event -50$/,/^event +36$/p' <<<"$trace")" ||
  fail "releasing a key held from before the mode does not end the chord" "$trace"
grep -qx "exec omarchy-menu-keybindings --describe 36" <<<"$trace" ||
  fail "a key released from before the mode is not part of the chord" "$trace"
pass "releasing a key held from before the mode does not end the chord"

# A modifier still held when the chord is done counts, ahead of the keys
# pressed in the submap, so the key pressed there still names the chord.
trace=$(describe_trace "133" +65 -65)
grep -qx "exec omarchy-menu-keybindings --describe 133 65" <<<"$trace" ||
  fail "a modifier held from before the mode is part of the chord" "$trace"
pass "a modifier held from before the mode is part of the chord"

# ESCAPE cancels, and the timer cancels on its own: both leave the submap and
# stop listening, so describe mode can't keep swallowing keys.
for ending in escape timeout; do
  trace=$(describe_trace "" "$ending")
  ending_trace=$(after "$ending" "$trace")
  grep -qx "exec omarchy-menu-keybindings --describe cancel" <<<"$ending_trace" ||
    fail "$ending cancels describe mode" "$trace"
  grep -qx "submap reset" <<<"$ending_trace" && grep -qx "stop listening" <<<"$ending_trace" ||
    fail "$ending leaves the submap and stops listening" "$trace"
  grep -qx "listening false" <<<"$trace" ||
    fail "nothing is left listening after $ending" "$trace"
done
pass "escape and the timeout cancel describe mode and leave the submap"

# Starting again while describe mode is up starts over rather than stacking a
# second listener and timer on the first.
trace=$(HOME="$tmpdir/home" OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
local active = 0
hl = setmetatable({
  dsp = setmetatable({}, { __index = function() return function() return {} end end }),
  on = function(event)
    if event ~= "input.keyboard.key" then return { remove = function() end } end
    active = active + 1
    local live = true
    return { remove = function() if live then live = false active = active - 1 end end }
  end,
  timer = function() return { set_enabled = function() end } end,
}, { __index = function() return function() return {} end end })
require("default.hypr.helpers")
dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bindings/utilities.lua")
o.describe_key()
o.describe_key()
print("listeners " .. active)
LUA
)
[[ $trace == "listeners 1" ]] ||
  fail "starting describe mode twice leaves one listener" "$trace"
pass "starting describe mode twice leaves one listener"
