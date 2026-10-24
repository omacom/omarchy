#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command lua

# Load the system window rules against a stub hl and o, open one window of the
# given class on the given workspace, and report what the window.open handlers dispatched.
dispatched() {
  local class="$1" workspace="$2"

  OMARCHY_PATH="$ROOT" CLASS="$class" WORKSPACE="$workspace" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local handlers = {}

o = { window = function() end }
hl = {
  on = function(event, handler)
    if event == "window.open" then
      table.insert(handlers, handler)
    end
  end,
  dsp = {
    focus = function(args)
      return "focus " .. args.window.address
    end,
    window = {
      fullscreen = function(args)
        return "fullscreen " .. args.mode .. " " .. args.action .. " " .. args.window.address
      end,
    },
  },
  dispatch = function(action)
    print(action)
  end,
}

require("default.hypr.apps.system")

for _, handler in ipairs(handlers) do
  handler({ address = "0xopened", class = os.getenv("CLASS"), workspace = { name = os.getenv("WORKSPACE") } })
end
LUA
}

expected=$(printf '%s\n' "focus 0xopened" "fullscreen fullscreen set 0xopened")
actual=$(dispatched org.omarchy.screensaver special:screensaver-DP-1)
[[ $actual == "$expected" ]] ||
  fail "an opening screensaver is focused and set fullscreen" "$actual"
pass "an opening screensaver is focused and set fullscreen"

actual=$(dispatched org.omarchy.screensaver special:screensaver)
[[ -z $actual ]] ||
  fail "a screensaver mapped again as it closes is left on its hidden workspace" "$actual"
pass "a screensaver mapped again as it closes is left on its hidden workspace"

actual=$(dispatched dev.zed.Zed 1)
[[ -z $actual ]] ||
  fail "other windows open untouched" "$actual"
pass "other windows open untouched"
