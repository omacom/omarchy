#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command lua

# Load the screensaver bindings against a stub hl that follows Hyprland's
# dispatcher contract: hl.dsp.window.close({ window? }) closes the window named
# by the table's `window` field, and the focused window when that field is
# absent. A window object passed on its own is not a table, so Hyprland treats
# it as absent too. Tap each modifier with two screensaver windows open and
# report which windows got a close request.
closes() {
  local focused="$1"

  OMARCHY_PATH="$ROOT" FOCUSED="$focused" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local windows = {
  { address = "0xsaver1", class = "org.omarchy.screensaver" },
  { address = "0xsaver2", class = "org.omarchy.screensaver" },
  { address = "0xeditor", class = "dev.zed.Zed" },
}

local focused
for _, window in ipairs(windows) do
  if window.address == os.getenv("FOCUSED") then
    focused = window
  end
end

local binds = {}

hl = {
  bind = function(keys, dispatcher)
    table.insert(binds, { keys = keys, dispatcher = dispatcher })
  end,
  get_windows = function(filter)
    local found = {}
    for _, window in ipairs(windows) do
      if not (filter and filter.class) or window.class == filter.class then
        table.insert(found, window)
      end
    end
    return found
  end,
  dsp = {
    window = {
      close = function(args)
        local target = type(args) == "table" and args.window or nil
        return { close = target or focused }
      end,
    },
  },
  dispatch = function(action)
    io.write(" " .. action.close.address)
  end,
}

require("default.hypr.bindings.screensaver")

for _, bind in ipairs(binds) do
  io.write(bind.keys .. ":")
  bind.dispatcher()
  io.write("\n")
end
LUA
}

expected=$(printf '%s: 0xsaver1 0xsaver2\n' \
  "SHIFT + SHIFT_L" "SHIFT + SHIFT_R" \
  "CTRL + CONTROL_L" "CTRL + CONTROL_R" \
  "ALT + ALT_L" "ALT + ALT_R" \
  "SUPER + SUPER_L" "SUPER + SUPER_R")

# A screensaver window exists but another window has focus, as while the
# launcher is still opening screensavers on later monitors.
closed=$(closes 0xeditor)
[[ $closed == "$expected" ]] ||
  fail "a lone modifier closes the screensaver windows, not the focused window" "$closed"
pass "a lone modifier closes the screensaver windows, not the focused window"

closed=$(closes 0xsaver1)
[[ $closed == "$expected" ]] ||
  fail "a lone modifier closes every screensaver window once" "$closed"
pass "a lone modifier closes every screensaver window once"
