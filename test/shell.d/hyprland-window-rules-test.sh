#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Print the no_focus rules the default config registers, one match per line.
no_focus_rules=$(HOME="$tmpdir" XDG_CONFIG_HOME="$tmpdir/.config" XDG_STATE_HOME="$tmpdir/.local/state" OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

hl = setmetatable({
  window_rule = function(rule)
    if rule.no_focus then
      local keys = {}
      for key, value in pairs(rule.match) do
        table.insert(keys, key .. "=" .. tostring(value))
      end
      table.sort(keys)
      print(table.concat(keys, " "))
    end
  end,
}, {
  __index = function()
    return function()
      return {}
    end
  end,
})

require("default.hypr.helpers")
require("default.hypr.windows")
LUA
)

grep -Fqx 'class=^$ float=true fullscreen=false pin=false title=^$' <<<"$no_focus_rules" ||
  fail "the no_focus rule matches empty class and title without an xwayland condition" "$no_focus_rules"
pass "the no_focus rule matches empty class and title without an xwayland condition"
