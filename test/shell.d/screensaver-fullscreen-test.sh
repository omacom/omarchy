#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command lua

# Load the system window rules against a stub hl and o, open one window of the
# given class, and report what the window.open handlers dispatched.
dispatched() {
  local class="$1"

  OMARCHY_PATH="$ROOT" CLASS="$class" lua <<'LUA'
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
  handler({ address = "0xopened", class = os.getenv("CLASS") })
end
LUA
}

expected=$(printf '%s\n' "focus 0xopened" "fullscreen fullscreen set 0xopened")
actual=$(dispatched org.omarchy.screensaver)
[[ $actual == "$expected" ]] ||
  fail "an opening screensaver is focused and set fullscreen" "$actual"
pass "an opening screensaver is focused and set fullscreen"

actual=$(dispatched dev.zed.Zed)
[[ -z $actual ]] ||
  fail "other windows open untouched" "$actual"
pass "other windows open untouched"
