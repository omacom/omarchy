#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua
require_command rg

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/home"

# Load the PiP rules with a recording o.window stub: this syntax-checks the
# file and reports every rule in order with its matchers and layout props.
rules_output=$(HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("HOME") .. "/.config/?.lua;" .. os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local rules = {}
o = {
  window = function(matchers, props)
    table.insert(rules, { matchers = matchers, props = props or {} })
  end,
}

require("default.hypr.apps.pip")

print("rules:" .. #rules)
for i, rule in ipairs(rules) do
  local matchers = rule.matchers
  local desc
  if type(matchers) == "string" then
    desc = "match=" .. matchers
  elseif type(matchers) == "table" then
    desc = "tag=" .. tostring(matchers.tag) .. " title=" .. tostring(matchers.title)
  else
    desc = "match=?"
  end
  print("rule:" .. i .. " " .. desc
    .. " tile=" .. tostring(rule.props.tile)
    .. " float=" .. tostring(rule.props.float)
    .. " pin=" .. tostring(rule.props.pin))
end
LUA
)

grep -Fq "rules:4" <<<"$rules_output" || fail "pip rules load all four window rules" "$rules_output"
pass "pip rules load"

grep -Fq 'title=^Meet - .+ tile=nil float=true pin=true' <<<"$rules_output" ||
  fail "meet overlay rule floats and pins" "$rules_output"
pass "meet overlay rule floats and pins"

grep -Fq 'title=^Meet - .+ - (Chromium|Google Chrome|Brave|Microsoft.Edge|Vivaldi|Helium)$ tile=true' <<<"$rules_output" ||
  fail "meet meeting-window rule tiles back" "$rules_output"
pass "meet meeting-window rule tiles back"

pip_line=$(grep -nF 'title=^Meet - .+ tile=nil' <<<"$rules_output" | cut -d: -f1)
retile_line=$(grep -nF 'tile=true' <<<"$rules_output" | cut -d: -f1)
(( pip_line < retile_line )) || fail "meeting-window rule runs after the overlay rule" "$rules_output"
pass "meeting-window rule runs after the overlay rule"

# The two title patterns must partition Meet windows: the bare overlay title
# keeps the PiP treatment while anything carrying a browser suffix tiles.
overlay_title="Meet - abc-defg-hij"
meeting_title="Meet - abc-defg-hij - Chromium"

rg -q '^Meet - .+' <<<"$overlay_title" || fail "overlay title matches the pip pattern"
rg -q '^Meet - .+ - (Chromium|Google Chrome|Brave|Microsoft.Edge|Vivaldi|Helium)$' <<<"$overlay_title" &&
  fail "overlay title avoids the meeting-window pattern"
pass "overlay title keeps the pip treatment"

rg -q '^Meet - .+ - (Chromium|Google Chrome|Brave|Microsoft.Edge|Vivaldi|Helium)$' <<<"$meeting_title" ||
  fail "meeting title matches the meeting-window pattern"
pass "meeting title tiles back"

rg -q '^Meet - .+ - (Chromium|Google Chrome|Brave|Microsoft.Edge|Vivaldi|Helium)$' <<<"Meet - Team Sync - Google Chrome" ||
  fail "meeting title matches other chromium browsers"
rg -q '^Meet - .+ - (Chromium|Google Chrome|Brave|Microsoft.Edge|Vivaldi|Helium)$' <<<"Some Doc - Chromium" &&
  fail "non-meet title avoids the meeting-window pattern"
pass "meeting-window pattern covers browsers without catching other titles"
