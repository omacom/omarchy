#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
require_command lua

timeout 10s lua - <<'LUA' || exit 1
local current, monitors, workspace, opened, timers, actions
o = { window = function() end }
hl = {
  on = function(event, callback)
    assert(event == "window.open")
    opened = callback
  end,
  timer = function(callback, opts)
    assert(opts.type == "oneshot")
    timers[#timers + 1] = callback
  end,
  get_windows = function() return current and { current } or {} end,
  get_window = function(selector)
    if current and selector == "address:" .. current.address then return current end
  end,
  get_monitors = function() return monitors end,
  get_active_workspace = function() return workspace end,
  dsp = { window = {
    move = function(args) return args end,
    center = function(args)
      args.kind = "center"
      return args
    end,
    alter_zorder = function(args) return args end,
  } },
  dispatch = function(args)
    actions[#actions + 1] = args
    if args.workspace then args.window.workspace = args.workspace end
    if args.kind == "center" then
      assert(args.window.workspace == workspace, "move to the destination workspace before centering")
      -- Simulate the compositor placing the window on screen; centering geometry is its responsibility.
      args.window.at = { x = workspace.monitor.x, y = workspace.monitor.y }
    end
  end,
}

local function setup(existing)
  current = {
    class = "jetbrains-toolbox", address = "0x123", stable_id = 1,
    xwayland = true, floating = true, mapped = true, hidden = false,
    at = { x = -440, y = 0 }, size = { x = 440, y = 700 },
  }
  monitors = {
    { x = 0, y = 0, width = 2560, height = 1440, scale = 1, transform = 0 },
    { x = 2560, y = 0, width = 2560, height = 1440, scale = 1, transform = 0 },
  }
  workspace = { monitor = monitors[2] }
  timers, actions = {}, {}
  local window = current
  if not existing then current = nil end
  dofile(os.getenv("ROOT") .. "/default/hypr/apps/jetbrains.lua")
  current = window
end

local function run_timers()
  for _, callback in ipairs(timers) do callback() end
end

setup()
opened(current)
assert(#actions == 0, "placement must wait for the application to settle")
run_timers()
assert(actions[1].workspace == workspace and actions[1].follow == false)
assert(actions[2].kind == "center" and actions[2].window == current, "ask Hyprland to center the recovered window")
assert(#actions == 3, "a recovered window must be left alone on the next check")
print("ok - off-screen Toolbox reopens on the active workspace")

for _, position in ipairs({ { 200, 100 }, { -439, 0 }, { 5000, 100 } }) do
  setup()
  current.at = { x = position[1], y = position[2] }
  opened(current)
  run_timers()
  assert(#actions == 0, "preserve windows intersecting any monitor")
end
print("ok - visible and partially visible positions are preserved")

setup()
monitors[1].x = -2560
opened(current)
run_timers()
assert(#actions == 0, "negative coordinates can belong to a monitor")
print("ok - monitors left of the origin are respected")

setup()
monitors = { { x = 100, y = -200, width = 3840, height = 2160, scale = 2, transform = 1 } }
workspace.monitor = monitors[1]
current.at = { x = 200, y = 1600 }
opened(current)
run_timers()
assert(#actions == 0, "the lower part of a scaled portrait monitor is visible")
current.at = { x = 1300, y = 0 }
run_timers()
assert(#actions == 3 and actions[2].kind == "center", "recover positions outside the scaled portrait monitor")
print("ok - scaled and rotated monitor bounds are respected")

for _, state in ipairs({ "closed", "hidden", "unmapped", "tiled", "replaced", "no-workspace" }) do
  setup()
  opened(current)
  if state == "closed" then current = nil
  elseif state == "hidden" then current.hidden = true
  elseif state == "unmapped" then current.mapped = false
  elseif state == "tiled" then current.floating = false
  elseif state == "replaced" then current.stable_id = 2
  elseif state == "no-workspace" then workspace = nil end
  run_timers()
  assert(#actions == 0, "ignore " .. state .. " windows")
end
print("ok - delayed callbacks ignore closed, changed, or unavailable windows")

for _, change in ipairs({ { "class", "jetbrains-idea" }, { "xwayland", false }, { "floating", false } }) do
  setup()
  current[change[1]] = change[2]
  opened(current)
  assert(#timers == 0, "only floating XWayland Toolbox windows need recovery")
end
print("ok - other JetBrains windows, native Wayland, and tiling are unaffected")

setup()
current.at = { x = 200, y = 100 }
opened(current)
timers[1]()
current.at = { x = -440, y = 0 }
timers[2]()
assert(#actions == 3 and actions[2].kind == "center", "recover when placement changes after the first check")
print("ok - late off-screen placement is recovered")

setup(true)
run_timers()
assert(#actions == 3 and actions[2].kind == "center", "reload recovers an existing off-screen window")
print("ok - configuration reload recovers existing Toolbox windows")

setup()
local noop
noop = setmetatable({}, {
  __index = function() return noop end,
  __call = function() return noop end,
})
hl.get_windows = function() return noop end
dofile(os.getenv("ROOT") .. "/default/hypr/apps/jetbrains.lua")
assert(#timers == 0, "the keybinding scanner's mock list contains no real windows")
print("ok - keybinding scanner mock does not hang configuration loading")
LUA
