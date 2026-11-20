#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

# #19601: Hyprland stacks pinned floating windows above unpinned ones
# regardless of focus, so a portal chooser dialog opened by a popped (pinned)
# window maps invisible behind its parent. Both chooser rules must pin.

OMARCHY_PATH="$ROOT" lua - <<'LUA' || fail "the portal chooser rules pin the dialog above popped windows"
o = { rules = {} }
function o.window(matcher, opts)
  if type(matcher) == "string" then matcher = { class = matcher } end
  table.insert(o.rules, { matcher = matcher, opts = opts or {} })
end

dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/apps/system.lua")

local function rule_for(class)
  for _, rule in ipairs(o.rules) do
    if rule.matcher.class == class then return rule end
  end
  return nil
end

for _, class in ipairs({ "xdg-desktop-portal-gtk", "folio-chooser" }) do
  local rule = rule_for(class)
  assert(rule, "a floating rule exists for " .. class)
  assert(rule.opts.tag == "+floating-window", class .. " keeps its float tag")
  assert(rule.opts.pin == true, class .. " pins above popped (pinned) windows")
end
LUA

pass "the portal chooser rules pin the dialog above popped windows"
