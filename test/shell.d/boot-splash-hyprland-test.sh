#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
theme="$stage/usr/share/plymouth/themes/omarchy"
mkdir -p "$theme" "$stage/run/plymouth"
png() {
  python3 - "$1" "$2" "$3" <<'PY'
import struct, sys, zlib
ihdr = struct.pack(">IIBBBBB", int(sys.argv[2]), int(sys.argv[3]), 8, 6, 0, 0, 0)
open(sys.argv[1], "wb").write(b"\x89PNG\r\n\x1a\n" + struct.pack(">I", 13) + b"IHDR" + ihdr + struct.pack(">I", zlib.crc32(b"IHDR" + ihdr)))
PY
}
png "$theme/entry.png" 286 48
png "$theme/progress_box.png" 300 10

# Runs default/hypr/boot-splash.lua against a stub Hyprland that knows (or not)
# the startup splash, with absolute paths read from the stage.
splash() {
  STAGE=$stage KNOWN=$1 SPLASH=${2:-} lua - "$ROOT/default/hypr/boot-splash.lua" <<'LUA'
local stage, known, splash = os.getenv("STAGE"), os.getenv("KNOWN") == "1", os.getenv("SPLASH")
local open = io.open
io.open = function(path, mode) return open(path:sub(1, 1) == "/" and stage .. path or path, mode) end
local config, env, animations = {}, {}, {}
hl = {
  get_config = function(key) if key == "misc.startup_splash_logo" and known then return "" end end,
  config = function(t) for k, v in pairs(t.misc or {}) do config[k] = v end end,
  env = function(k, v) env[k] = v end,
  animation = function(t) animations[t.leaf] = t.enabled end,
}
o = { splash_background = function() return splash ~= "" and splash or nil end }
dofile(arg[1])
print(string.format("logo=%s bar=%s offset=%s start=%s scale=%s env=%s zoom=%s",
  tostring(config.startup_splash_logo), tostring(config.startup_splash_bar), tostring(config.startup_splash_bar_offset),
  tostring(config.startup_splash_bar_start), tostring(config.startup_splash_scale), tostring(env.OMARCHY_HYPRLAND_SPLASH),
  tostring(animations.monitorAdded)))
LUA
}

echo 4242 >"$stage/run/plymouth/pid"
printf '7215 1\n' >"$stage/run/omarchy-boot-splash-bar"
output=$(splash 1 1e1e2d)
[[ $output == "logo=/usr/share/plymouth/themes/omarchy/logo.png bar=/usr/share/plymouth/themes/omarchy/progress_bar.png offset=59.0 start=7215 scale=1 env=1 zoom=false" ]] ||
  fail "Hyprland draws the splash, with the bar Plymouth's stood at" "$output"
pass "Hyprland draws the splash, with the bar Plymouth's stood at"

rm "$stage/run/omarchy-boot-splash-bar"
output=$(splash 1 1e1e2d)
[[ $output == *"start=0 scale=0 "* ]] || fail "a boot that asked no password draws no bar, at the scale Plymouth would pick" "$output"
pass "a boot that asked no password draws no bar"

output=$(splash 0 1e1e2d)
[[ $output == *"logo=nil"*"env=nil"* ]] || fail "a Hyprland without the startup splash is left alone" "$output"
output=$(splash 1 "")
[[ $output == *"logo=nil"* ]] || fail "another Plymouth theme has no splash to carry on" "$output"
rm "$stage/run/plymouth/pid"
output=$(splash 1 1e1e2d)
[[ $output == *"logo=nil"* ]] || fail "a config reload after Plymouth quit brings no splash back" "$output"
pass "the splash is only drawn at login, by a Hyprland that can, after Omarchy's Plymouth theme"
