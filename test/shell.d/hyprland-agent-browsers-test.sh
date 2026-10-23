#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

# The real helpers load against a stubbed hl; the rule and the binding print what they hand to Hyprland.
output=$(OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
local function dispatcher(path)
  return setmetatable({}, {
    __index = function(_, name) return dispatcher(path .. "." .. name) end,
    __call = function(_, arg) return { call = path .. "(" .. (type(arg) == "string" and arg or "...") .. ")" } end,
  })
end
hl = setmetatable({
  dsp = dispatcher("hl.dsp"),
  window_rule = function(rule)
    if rule.workspace then
      print("rule\t" .. rule.match.class .. "\t" .. rule.workspace .. "\t" .. (rule.suppress_event or ""))
    end
  end,
  bind = function(keys, dispatcher, opts) print("bind\t" .. keys .. "\t" .. opts.description .. "\t" .. dispatcher.call) end,
}, { __index = function() return function() return {} end end })
require("default.hypr.helpers")
require("default.hypr.apps.agent-browsers")
require("default.hypr.bindings.tiling")
LUA
)

IFS=$'\t' read -r _ pattern workspace suppressed < <(grep '^rule' <<<"$output" || true)
[[ -n ${pattern:-} ]] || fail "the agent browser rule loads" "$output"

# Hyprland matches a class pattern against the whole class, so a bare prefix matches only a class that is exactly that prefix.
[[ agent-brave-work =~ ^($pattern)$ ]] || fail "agent-<name> classes match the rule" "$pattern"
pass "agent-<name> classes match the rule"

for class in chromium brave-browser; do
  [[ $class =~ ^($pattern)$ ]] && fail "$class is not an agent browser" "$pattern"
done
pass "ordinary browser classes do not match"

[[ $workspace == "special:agents silent" ]] || fail "agent browsers open silently on their own workspace" "$workspace"
pass "agent browsers open silently on their own workspace"

for event in activate fullscreen; do
  [[ " $suppressed " == *" $event "* ]] || fail "agent browsers suppress $event" "$suppressed"
done
pass "agent browsers suppress activate and fullscreen"

grep -Fxq $'bind\tSUPER + ALT + A\tToggle agent browsers\thl.dsp.workspace.toggle_special(agents)' <<<"$output" ||
  fail "Super + Alt + A toggles the agents workspace" "$output"
pass "Super + Alt + A toggles the agents workspace"
