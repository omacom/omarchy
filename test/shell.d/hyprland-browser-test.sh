#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command lua

if lua <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path

local rules = {}
hl = {
  window_rule = function(rule)
    table.insert(rules, rule)
  end,
}

require("default.hypr.helpers")
require("default.hypr.apps.browser")

local fullscreen_rules = 0
local has_chromium_rule = false
local has_firefox_rule = false
local has_video_app_rule = false

for _, rule in ipairs(rules) do
  if rule.idle_inhibit == "fullscreen" then
    fullscreen_rules = fullscreen_rules + 1
    local class = rule.match.class or ""
    has_chromium_rule = has_chromium_rule or class:find("hrom", 1, true) ~= nil
    has_firefox_rule = has_firefox_rule or class:find("irefox", 1, true) ~= nil
    has_video_app_rule = has_video_app_rule or class:find("youtube", 1, true) ~= nil
  end
end

assert(fullscreen_rules == 3, "expected fullscreen idle inhibition for browsers and video web apps")
assert(has_chromium_rule, "missing Chromium-based browser fullscreen idle inhibition")
assert(has_firefox_rule, "missing Firefox-based browser fullscreen idle inhibition")
assert(has_video_app_rule, "missing video web app fullscreen idle inhibition")
LUA
then
  pass "browser fullscreen idle inhibition rules load correctly"
else
  fail "browser fullscreen idle inhibition rules load correctly"
fi
