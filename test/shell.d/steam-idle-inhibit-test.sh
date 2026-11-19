#!/bin/bash

# #6947 / #15329: Steam games are steam_app_<id>, often borderless; the client
# rule on class "steam" never matches them, and "fullscreen" would miss too.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

STEAM_IDLE_RULES=$(OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

hl = {
  window_rule = function(rule)
    if rule.idle_inhibit then
      print(rule.match.class .. "\t" .. rule.idle_inhibit)
    end
  end,
}

require("default.hypr.helpers")
require("default.hypr.apps.steam")
LUA
) || fail "steam.lua loads under a stubbed Hyprland API"
export STEAM_IDLE_RULES

run_node_test <<'JS'
const rules = process.env.STEAM_IDLE_RULES.trim().split('\n').map(line => {
  const [pattern, mode] = line.split('\t')
  return { pattern: new RegExp(`^(?:${pattern})$`), mode }
})
const modesFor = cls => rules.filter(rule => rule.pattern.test(cls)).map(rule => rule.mode)

for (const cls of ['steam_app_1091500', 'steam_app_570', 'steam_app_244210', 'gamescope']) {
  assertDeepEqual(modesFor(cls), ['focus'], `${cls} inhibits idle while focused (borderless or fullscreen)`)
}

assertDeepEqual(modesFor('steam'), ['fullscreen'], 'Steam client keeps fullscreen-only idle inhibit')

for (const cls of ['foot', 'firefox', 'chromium', 'steam_app_', 'other_steam_app_1091500']) {
  assertDeepEqual(modesFor(cls), [], `${cls} receives no Steam idle inhibitor`)
}
JS

pass "Steam games and gamescope inhibit idle while focused"
