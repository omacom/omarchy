#!/bin/bash

# #15309: Helium's "Profile error occurred" dialogs arrive with an empty class, so a rule cannot
# match one; tiled, six or seven of them divide the workspace into unreadable slivers. Load the
# browser rules with a stub `o` and ask the title patterns about the dialog's actual title.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

cat >"$tmpdir/rules.lua" <<'LUA'
local rules = {}
o = {
  window = function(pattern, options)
    rules[#rules + 1] = { pattern = pattern, options = options }
  end
}
dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/apps/browser.lua")

local dialog_floats, sharing_kept = false, false
for _, rule in ipairs(rules) do
  local pattern, options = rule.pattern, rule.options or {}
  -- Title rules only: string.match is a Lua pattern match, which is faithful for a title with no
  -- alternation, but not for the class rules above (Hyprland alternation is not a Lua pattern).
  if type(pattern) == "table" and pattern.title then
    if string.match("Profile error occurred", pattern.title) then
      dialog_floats = options.float == true
    end
    if string.match("a window is sharing its screen", pattern.title) and options.workspace then
      sharing_kept = true
    end
  end
end
print(dialog_floats and "dialog:floats" or "dialog:tiled")
print(sharing_kept and "sharing:kept" or "sharing:lost")
LUA

output=$(OMARCHY_PATH="$ROOT" lua "$tmpdir/rules.lua")

grep -qx 'sharing:kept' <<<"$output" ||
  fail "the browser rules still hide the screen-sharing window" "$output"
grep -qx 'dialog:floats' <<<"$output" ||
  fail "a profile-error dialog floats instead of taking a tile" "$output"
pass "a Helium profile-error dialog floats"
