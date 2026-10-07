#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command lua

# Two overlapping pinned windows, b above a, go through a screensaver and must come back pinned in the same order.
# A pop-out is raised when it is pinned and a picture-in-picture window, pinned by a rule, is not, so a need not be raised.
cycle() {
  A_RAISED=$1 OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local stack, handlers = {}, {}
local function window(class, raised)
  local w = { class = class, pinned = true, allowed_over_fullscreen = raised, tags = {} }
  stack[#stack + 1] = w
  return w
end
local function move(w, to_top)
  for i, v in ipairs(stack) do
    if v == w then table.remove(stack, i) break end
  end
  if to_top then table.insert(stack, w) else table.insert(stack, 1, w) end
end
local actions = {
  pin = function(a) a.window.pinned = a.action == "on" end,
  tag = function(a) a.window.tags[a.tag:sub(2)] = a.tag:sub(1, 1) == "+" or nil end,
  alter_zorder = function(a)
    move(a.window, a.mode == "top")
    a.window.allowed_over_fullscreen = a.mode == "top"
  end,
}

hl = setmetatable({
  dsp = { window = setmetatable({}, { __index = function(_, name) return function(a) return { name, a } end end }) },
  dispatch = function(d) if actions[d[1]] then actions[d[1]](d[2]) end end,
  on = function(event, fn) handlers[event] = fn end,
  get_windows = function(filter)
    local found = {}
    for _, w in ipairs(stack) do
      if not filter or (filter.class and w.class == filter.class) or (filter.tag and w.tags[filter.tag]) then
        found[#found + 1] = w
      end
    end
    return found
  end,
}, { __index = function() return function() return {} end end })

require("default.hypr.helpers")
require("default.hypr.apps.screensaver")

window("a", os.getenv("A_RAISED") == "true")
window("b", true)
local saver = { class = "org.omarchy.screensaver", pinned = false, tags = {} }
handlers["window.open_early"](saver)
stack[#stack + 1] = saver
handlers["window.open"](saver)

local function pins()
  local out = {}
  for _, w in ipairs(stack) do
    if w ~= saver then out[#out + 1] = w.class .. (w.pinned and "+" or "-") end
  end
  return table.concat(out, " ")
end

local during = pins()
table.remove(stack)
handlers["window.destroy"](saver)
print(during .. " | " .. pins())
LUA
}

order=$(cycle true)
[[ $order == "a- b- | "* ]] || fail "the screensaver unpins the windows pinned over it" "bottom to top: $order"
pass "the screensaver unpins the windows pinned over it"
[[ $order == *" | a+ b+" ]] || fail "pinned windows come back pinned in the order they had" "bottom to top: $order"
pass "pinned windows come back pinned in the order they had"

order=$(cycle false)
[[ $order == "a- b- | a+ b+" ]] ||
  fail "a window pinned without a raise keeps its place under a pop-out" "bottom to top: $order"
pass "a window pinned without a raise keeps its place under a pop-out"
