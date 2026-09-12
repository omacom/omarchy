#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Stock XF86Touchpad* binds need input:resolve_binds_by_sym (issue #10449).
# Without it Hyprland's default false reverse-lookup never reaches keycode 538.

require_command lua

input_lua="$ROOT/default/hypr/input.lua"
media_lua="$ROOT/default/hypr/bindings/media.lua"

[[ -f $input_lua ]] || fail "default hypr input config exists"
[[ -f $media_lua ]] || fail "default hypr media bindings exist"

# Defaults must ship the option; a bare presence check is not enough — assert
# the live hl.config table the session actually loads.
resolved=$(
  OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

io.open = function(path, mode)
  if path == "/etc/vconsole.conf" then return nil end
  return io.tmpfile()
end

hl = {
  config = function(config)
    local input = config.input or {}
    if input.resolve_binds_by_sym == true then
      print("resolve_binds_by_sym=true")
    elseif input.resolve_binds_by_sym == false then
      print("resolve_binds_by_sym=false")
    else
      print("resolve_binds_by_sym=missing")
    end
  end,
}

o = { window = function() end }

require("default.hypr.input")
LUA
)

[[ $resolved == "resolve_binds_by_sym=true" ]] ||
  fail "default hypr input enables resolve_binds_by_sym" "actual: $resolved"
pass "default hypr input enables resolve_binds_by_sym"

# The media binds that depend on symbol resolution must still be present.
for needle in XF86TouchpadToggle XF86TouchpadOn XF86TouchpadOff; do
  grep -F "$needle" "$media_lua" >/dev/null ||
    fail "media bindings still register $needle by keysym"
done
pass "media bindings still register XF86Touchpad* by keysym"

# Comment must keep the issue pointer so a future drive-by drop is reviewed.
grep -F '#10449' "$input_lua" >/dev/null ||
  fail "input.lua documents issue #10449 next to resolve_binds_by_sym"
pass "input.lua documents issue #10449 next to resolve_binds_by_sym"
