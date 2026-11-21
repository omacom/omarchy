#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

# The built-in trackpad's custom acceleration must stay a valid libinput curve:
# a positive step and 2 to 64 numeric points, starting at 0 and never slowing
# down, with a well-formed scroll curve beside it (else scrolling is unaccelerated).
result=$(OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local devices = {}
hl = {
  config = function() end,
  device = function(device)
    devices[#devices + 1] = device
  end,
}
o = { window = function() end }

require("default.hypr.input")

-- A step and points, as libinput takes them, or nil and what is wrong.
local function curve(text)
  if type(text) ~= "string" then
    return nil, "missing"
  end
  local values = {}
  for field in text:gmatch("%S+") do
    local value = tonumber(field)
    if not value then
      return nil, "not a number: " .. field
    end
    values[#values + 1] = value
  end
  if not values[1] or values[1] <= 0 then
    return nil, "no positive step"
  end
  local points = #values - 1
  if points < 2 or points > 64 then
    return nil, ("%d points, libinput takes 2 to 64"):format(points)
  end
  for i = 2, #values do
    if values[i] < 0 then
      return nil, "negative point " .. (i - 1)
    end
  end
  return values
end

local function check(trackpad)
  local accel = trackpad.accel_profile or ""
  if not accel:match("^custom%s") then
    return "not a custom profile: " .. accel
  end
  local values, problem = curve((accel:gsub("^custom%s+", "")))
  if not values then
    return "accel_profile: " .. problem
  end
  if values[2] ~= 0 then
    return "first point is not 0"
  end
  for i = 3, #values do
    if values[i] < values[i - 1] then
      return "output speed drops at point " .. (i - 1)
    end
  end
  local _, scroll_problem = curve(trackpad.scroll_points)
  if scroll_problem then
    return "scroll_points: " .. scroll_problem
  end
  return "ok"
end

local trackpad
for _, device in ipairs(devices) do
  if device.name == "apple-mtp-multi-touch" then
    trackpad = device
  end
end
print(trackpad and check(trackpad) or "no apple-mtp-multi-touch device")
LUA
)

[[ $result == "ok" ]] || fail "trackpad curve is a valid libinput custom profile" "$result"
pass "trackpad curve is a valid libinput custom profile"
