#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

# Omarchy turns misc:focus_on_activate on globally (Hyprland defaults it off), so a
# browser that is handed a URL by another process asks to be focused and the view
# jumps to whichever workspace its window lives on. Load the app rules with a stub
# hl and check both browser families opt out of activation requests.
output=$(OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local rules = {}
local function ignore() end

hl = {
  config = ignore,
  env = ignore,
  monitor = ignore,
  workspace_rule = ignore,
  layer_rule = ignore,
  gesture = ignore,
  animation = ignore,
  curve = ignore,
  bind = ignore,
  unbind = ignore,
  exec_cmd = ignore,
  dispatch = ignore,
  on = ignore,
  timer = ignore,
  dsp = setmetatable({}, { __index = function() return function() return {} end end }),
  window_rule = function(rule) rules[#rules + 1] = rule end,
}

require("default.hypr.helpers")
require("default.hypr.apps.browser")

for _, rule in ipairs(rules) do
  local class = rule.match and rule.match.class
  if class and type(rule.tag) == "string" and rule.tag:sub(1, 1) == "+" then
    print(rule.tag .. "\t" .. tostring(rule.focus_on_activate))
  end
end
LUA
)

grep -Fqx $'+chromium-based-browser\tfalse' <<<"$output" ||
  fail "chromium-based browsers ignore activation requests" "$output"
pass "chromium-based browsers ignore activation requests"

grep -Fqx $'+firefox-based-browser\tfalse' <<<"$output" ||
  fail "firefox-based browsers ignore activation requests" "$output"
pass "firefox-based browsers ignore activation requests"
