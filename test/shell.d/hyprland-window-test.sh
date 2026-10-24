#!/bin/bash

source "$(dirname "$0")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

cat >"$tmpdir/hyprctl" <<'BASH'
#!/bin/bash

if [[ $1 == "activewindow" && $2 == "-j" ]]; then
  printf '{"fullscreenClient":%s}\n' "${HYPR_FULLSCREEN_CLIENT:-0}"
  exit 0
fi

if [[ $1 == "dispatch" ]]; then
  printf '%s\n' "$*" >>"$HYPRCTL_LOG"
  exit 0
fi

exit 1
BASH
chmod +x "$tmpdir/hyprctl"

log="$tmpdir/hyprctl.log"
PATH="$tmpdir:$PATH" HYPRCTL_LOG="$log" HYPR_FULLSCREEN_CLIENT=0 \
  "$ROOT/bin/omarchy-hyprland-window-tiled-fullscreen-toggle"

grep -Fq 'hl.dsp.window.fullscreen_state({ internal = 0, client = 2 })' "$log" || \
  fail "tiled fullscreen enables client fullscreen"
pass "tiled fullscreen enables client fullscreen"

>"$log"
PATH="$tmpdir:$PATH" HYPRCTL_LOG="$log" HYPR_FULLSCREEN_CLIENT=2 \
  "$ROOT/bin/omarchy-hyprland-window-tiled-fullscreen-toggle"

grep -Fq 'hl.dsp.window.fullscreen_state({ internal = 0, client = 0 })' "$log" || \
  fail "tiled fullscreen disables client fullscreen"
pass "tiled fullscreen disables client fullscreen"

# Hyprland lets a floating window focused over a fullscreen one keep drawing
# above it, and raising the fullscreen window does not take that back.
require_command lua
reveal=$(OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local active
local function window(address, workspace, fullscreen)
  return { address = address, workspace = { id = workspace }, fullscreen = fullscreen }
end
-- Bottom of the stack first, as Hyprland lists them.
local windows = {
  window("0xa", 1, 0), window("0xb", 2, 0), window("0xc", 1, 0),
  window("0xd", 1, 0), window("0xe", 1, 0), window("0xf", 1, 2),
}

hl = {
  dsp = { window = {
    bring_to_top = function() return "top" end,
    alter_zorder = function(arg) return arg.mode .. " " .. arg.window.address end,
  } },
  dispatch = function(dispatcher) print(dispatcher) end,
  get_active_window = function() return active end,
  get_windows = function() return windows end,
}

require("default.hypr.helpers")
local reveal = o.reveal_active_window()
active = windows[6]
reveal()
print("--")
windows[6].fullscreen = 1
reveal()
print("--")
active = windows[5]
reveal()
LUA
)
[[ $reveal == $'top\nbottom 0xe\nbottom 0xd\nbottom 0xc\nbottom 0xa\n--\ntop\nbottom 0xe\nbottom 0xd\nbottom 0xc\nbottom 0xa\n--\ntop' ]] ||
  fail "raising a fullscreen window lowers its workspace beneath it, in order" "$reveal"
pass "raising a fullscreen window lowers its workspace beneath it, in order"
