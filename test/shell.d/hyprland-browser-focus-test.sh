#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

# Omarchy turns misc:focus_on_activate on globally (Hyprland defaults it off), so a
# browser that is handed a URL by another process asks to be focused and the view
# jumps to whichever workspace its window lives on. Load the app rules with a stub
# hl and check which windows opt out of activation requests: the browsers
# themselves, and not the web apps that share the Chromium family's window-class
# prefix (chrome-<host>_<path>-Default) -- those lean on their activation request
# being honoured, because clicking one of their notifications runs the
# notification's default action and only falls back to raising the sender by class
# when nothing was invoked.
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

-- A rule that opts back in must not read as an opt-out: the classification keys
-- on the value, not on the key being set, so a future focus_on_activate = true
-- cannot pass this test unnoticed.
o.window("focus-on-activate-probe", { focus_on_activate = true })

for _, rule in ipairs(rules) do
  local class = rule.match and rule.match.class
  if type(class) == "string" then
    if rule.focus_on_activate == false then
      print("opt-out\t" .. class)
    elseif type(rule.tag) == "string" and rule.tag:sub(1, 1) == "+" then
      print("tag\t" .. rule.tag .. "\t" .. class)
    end
  end
end
LUA
)

# A Chromium web app's window class, as omarchy-webapp-window-class names it.
web_app_class=chrome-web.whatsapp.com__-Default

matches() { grep -Eq -- "$1" <<<"$2"; }

opt_outs=()
while IFS=$'\t' read -r kind class; do
  [[ $kind == opt-out ]] && opt_outs+=("$class")
done <<<"$output"

(( ${#opt_outs[@]} > 0 )) || fail "the browser rules opt out of activation requests" "$output"

opt_out_matches() {
  local class=$1 pattern

  for pattern in "${opt_outs[@]}"; do
    matches "$pattern" "$class" && return 0
  done

  return 1
}

opt_out_matches google-chrome || fail "google-chrome ignores activation requests" "$output"
opt_out_matches chromium || fail "chromium ignores activation requests" "$output"
# Chromium reports both on one machine: the same window class follows the
# desktop entry it was started from.
opt_out_matches chromium-browser || fail "chromium-browser ignores activation requests" "$output"
opt_out_matches google-chrome-stable || fail "a Chrome release suffix still opts out" "$output"
opt_out_matches google-chrome-beta || fail "a Chrome beta release still opts out" "$output"
# Brave and Edge ship their channels as separate packages with their own window
# class; the family tag catches them, so the opt-out has to as well.
opt_out_matches brave-browser || fail "brave-browser ignores activation requests" "$output"
opt_out_matches Brave-browser-beta || fail "a Brave channel build still opts out" "$output"
opt_out_matches microsoft-edge || fail "microsoft-edge ignores activation requests" "$output"
opt_out_matches microsoft-edge-dev || fail "an Edge channel build still opts out" "$output"
opt_out_matches Vivaldi-snapshot || fail "a Vivaldi snapshot still opts out" "$output"
pass "chromium-based browsers ignore activation requests"

opt_out_matches firefox || fail "firefox ignores activation requests" "$output"
opt_out_matches librewolf || fail "librewolf ignores activation requests" "$output"
pass "firefox-based browsers ignore activation requests"

! opt_out_matches "$web_app_class" ||
  fail "web apps keep their activation requests, so a notification click can raise them" "$output"
pass "web apps keep their activation requests"

# The regression guard above only bites if a rule that opts back in reads as an
# opt-out -- prove the classification is on the value.
! opt_out_matches focus-on-activate-probe ||
  fail "a rule that opts back in is not read as an opt-out" "$output"
pass "only an explicit opt-out counts as one"

# apps/pip.lua and the video rules float web apps by dropping this tag, so web
# apps have to keep carrying it.
tagged=0
while IFS=$'\t' read -r kind tag class; do
  [[ $kind == tag && $tag == +chromium-based-browser ]] && matches "$class" "$web_app_class" && tagged=1
done <<<"$output"
(( tagged == 1 )) || fail "web apps still carry the chromium browser tag" "$output"
pass "web apps still carry the chromium browser tag"
