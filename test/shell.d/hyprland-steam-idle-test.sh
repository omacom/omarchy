#!/bin/bash

# #15329: Proton games run as `steam_app_<appid>` and often borderless, so a rule that only matches
# the Steam client's class, or only in "fullscreen", leaves the machine to lock itself mid-game.
# Load the app rule with a stub `o` and match the pattern against a real game class.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

cat >"$tmpdir/rules.lua" <<'LUA'
-- Collect the window rules on the app config, then ask each pattern about the class Archinstall
-- reports for a running Proton game.
local rules = {}
o = {
  window = function(pattern, options)
    rules[#rules + 1] = { pattern = pattern, options = options }
  end
}
dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/apps/steam.lua")

local saw_client = false
for _, rule in ipairs(rules) do
  local pattern = type(rule.pattern) == "table" and rule.pattern.class or rule.pattern
  local inhibit = rule.options and rule.options.idle_inhibit
  if pattern == "steam" and inhibit then saw_client = true end
  if pattern and pattern ~= "steam" and inhibit and inhibit ~= "fullscreen"
     and string.match("steam_app_2358720", pattern) then
    print("game:" .. inhibit)
  end
end
print(saw_client and "client:set" or "client:missing")
LUA

output=$(OMARCHY_PATH="$ROOT" lua "$tmpdir/rules.lua")

grep -qx 'client:set' <<<"$output" ||
  fail "the Steam client still inhibits idle" "$output"
grep -q '^game:' <<<"$output" ||
  fail "a Proton game's class inhibits idle without needing fullscreen" "$output"
pass "a Proton game's class inhibits idle even when it runs borderless"
