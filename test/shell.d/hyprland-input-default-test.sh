#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
require_command lua
lua - "$ROOT" <<'LUA'
local root = arg[1]
local devices = {}
local config
hl = {
  config = function(value) config = value end,
  device = function(value) devices[value.name] = value end,
}
o = { window = function() end }
dofile(root .. "/default/hypr/input.lua")
assert(config.input.touchpad.tap_to_click == nil, "no global tap override")
assert(config.input.touchpad.natural_scroll == false, "traditional scrolling")
assert(devices["apple-mtp-multi-touch"].tap_to_click == false, "Apple tap disabled")
local count = 0
for _ in pairs(devices) do count = count + 1 end
assert(count == 2, "only Apple devices are overridden")
assert(devices["apple-spi-trackpad"].tap_to_click == false, "Apple SPI tap disabled")
local user = assert(io.open(root .. "/config/hypr/input.lua")):read("*a")
for override in user:gmatch("%-%- (hl%.device%([^\n]+)") do
  assert(load(override))()
end
assert(devices["apple-mtp-multi-touch"].tap_to_click == true, "MTP user override wins")
assert(devices["apple-spi-trackpad"].tap_to_click == true, "SPI user override wins")
LUA
pass "Apple-only touchpad default and documented user override"
