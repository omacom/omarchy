#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

# Load default/hypr/nvidia.lua with stubbed detectors and record the environment
# it would apply. The shell test next door covers the detector's exit status;
# this covers which variables the Lua module actually sets in each branch, so a
# mistake in the GSP/non-GSP gating cannot pass unnoticed.
resolved_env() {
  OMARCHY_PATH="$ROOT" NV_SCENARIO="$1" lua - <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local scenario = os.getenv("NV_SCENARIO")
local gsp_display = scenario == "gsp_display"
local gsp_nodisplay = scenario == "gsp_nodisplay"
local nogsp_display = scenario == "nogsp_display"
local nogsp_nodisplay = scenario == "nogsp_nodisplay"

local function ends_with(value, suffix)
  return value:sub(-#suffix) == suffix
end

o = {
  shell_quote = function(command)
    return command
  end,
  shell_succeeds = function(command)
    if ends_with(command, "/omarchy-hw-nvidia") then
      return scenario ~= "none"
    elseif ends_with(command, "/omarchy-hw-nvidia-display") then
      return gsp_display or nogsp_display
    elseif ends_with(command, "/omarchy-hw-nvidia-gsp") then
      return gsp_display or gsp_nodisplay
    elseif ends_with(command, "/omarchy-hw-nvidia-without-gsp") then
      return nogsp_display or nogsp_nodisplay
    else
      return false
    end
  end,
}

local applied = {}
hl = {
  env = function(name, value)
    applied[name] = value
  end,
}

require("default.hypr.nvidia")

local names = {}
for name in pairs(applied) do
  names[#names + 1] = name
end
table.sort(names)

for _, name in ipairs(names) do
  print(name .. "=" .. applied[name])
end
LUA
}

assert_env() {
  local description="$1"
  local scenario="$2"
  local expected="$3"
  local actual

  actual=$(resolved_env "$scenario") || fail "$description" "loading default/hypr/nvidia.lua failed"

  [[ $actual == "$expected" ]] ||
    fail "$description" "expected: ${expected:-<none>}"$'\n'"actual:   ${actual:-<none>}"
  pass "$description"
}

assert_env "a machine without an NVIDIA GPU sets no environment" "none" ""

assert_env "an NVIDIA display GPU with GSP forces VA-API and GLX" "gsp_display" \
  $'LIBVA_DRIVER_NAME=nvidia\nNVD_BACKEND=direct\n__GLX_VENDOR_LIBRARY_NAME=nvidia'

assert_env "a hybrid iGPU display with GSP keeps only NVD_BACKEND" "gsp_nodisplay" \
  'NVD_BACKEND=direct'

assert_env "an NVIDIA display GPU without GSP forces GLX only" "nogsp_display" \
  $'NVD_BACKEND=egl\n__GLX_VENDOR_LIBRARY_NAME=nvidia'

assert_env "a hybrid iGPU display without GSP keeps only NVD_BACKEND" "nogsp_nodisplay" \
  'NVD_BACKEND=egl'
