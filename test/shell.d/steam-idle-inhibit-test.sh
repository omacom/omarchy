#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

# Execute the real config and helper, capturing rules at Hyprland's API boundary.
STEAM_IDLE_RULES=$(OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
hl = {
  window_rule = function(rule)
    if rule.idle_inhibit then
      print(rule.match.class .. "\t" .. rule.idle_inhibit)
      assert(rule.match.fullscreen == nil, "game protection must include windowed mode")
    end
  end,
}
require("default.hypr.helpers")
require("default.hypr.apps.steam")
LUA
)
export STEAM_IDLE_RULES

run_node_test <<'JS'
const output = process.env.STEAM_IDLE_RULES
const rules = output.trim().split('\n').map(line => {
  const [pattern, mode] = line.split('\t')
  return { pattern: new RegExp(`^(?:${pattern})$`), mode }
})
const modesFor = cls => rules.filter(rule => rule.pattern.test(cls)).map(rule => rule.mode)

for (const cls of ['steam_app_1091500', 'steam_app_570', 'steam_app_123456789']) {
  assertDeepEqual(modesFor(cls), ['focus'], `${cls} inhibits idle while focused in either window mode`)
}
assertDeepEqual(modesFor('steam'), ['fullscreen'], 'Steam client keeps its existing fullscreen-only behavior')
for (const cls of ['foot', 'firefox', 'steam_app_', 'steam_app_1091500_extra', 'other_steam_app_1091500']) {
  assertDeepEqual(modesFor(cls), [], `${cls} receives no Steam idle inhibitor`)
}
JS
