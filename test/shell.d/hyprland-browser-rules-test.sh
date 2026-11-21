#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

# Chromium-based browsers raise one classless "Profile error occurred" dialog per failed profile
# database, and they must float. No class: "^$" would exempt every classless window from floating workspaces.
rules=$(OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
hl = setmetatable({
  window_rule = function(rule)
    if rule.tag == "+floating-window" then
      print((rule.match.class or "") .. "\t" .. (rule.match.title or ""))
    end
  end,
}, { __index = function() return function() return {} end end })
require("default.hypr.helpers")
require("default.hypr.apps.browser")
LUA
)

[[ $rules == $'\t^Profile error occurred$' ]] ||
  fail "browser profile error dialogs float by title alone" "floating-window rules: ${rules:-none}"
pass "browser profile error dialogs float by title alone"
