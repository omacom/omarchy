#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

grep -Fx 'require("default.hypr.monitor-removal")' "$ROOT/default/hypr/omarchy.lua" >/dev/null ||
  fail "the Omarchy Hyprland config loads the monitor removal handler"
pass "the Omarchy Hyprland config loads the monitor removal handler"

# Replays the event order of Hyprland 0.56.2's CMonitor::onDisconnect: focus is
# warped to the first remaining monitor, and monitor.focused fires while the
# monitor being left is still the active one (FocusState.cpp rawMonitorFocus).
# The removed monitor's workspaces then move over hidden and monitor.removed
# fires, all in one event-loop turn. hl.timer callbacks only run once that turn
# is over.
OMARCHY_PATH="$ROOT" lua - <<'LUA' || fail "a monitor removal keeps the focused workspace in front"
local handlers, timers, dispatched = {}, {}, {}
local monitors, focused, workspaces, after_dispatch

local function reset()
  monitors = {
    ["eDP-1"] = { name = "eDP-1", active = { id = 1, name = "1" } },
    ["USB-2"] = { name = "USB-2", active = { id = 5, name = "5" } },
  }
  focused = "eDP-1"
  workspaces = { ["1"] = true, ["5"] = true, ["name:notes"] = true }
  dispatched = {}
  after_dispatch = nil
end

-- Like rawMonitorFocus, which returns early when the monitor is unchanged.
local function focus_moves(to, assign_first)
  if focused == to then return end
  if assign_first then focused = to end
  handlers["monitor.focused"]({ name = to })
  focused = to
end

local function switch_workspace(id)
  monitors[focused].active = { id = id, name = tostring(id) }
  workspaces[tostring(id)] = true
  handlers["workspace.active"](monitors[focused].active)
end

hl = {
  on = function(event, callback)
    handlers[event] = callback
  end,
  timer = function(callback, opts)
    assert(opts.type == "oneshot" and opts.timeout > 0)
    table.insert(timers, callback)
  end,
  get_active_monitor = function()
    return monitors[focused]
  end,
  get_active_workspace = function(monitor)
    return (monitor or monitors[focused]).active
  end,
  get_active_special_workspace = function(monitor)
    return (monitor or monitors[focused]).special
  end,
  get_workspace = function(selector)
    return workspaces[selector] and {} or nil
  end,
  dispatch = function(action)
    table.insert(dispatched, action.workspace)
    -- Focusing a workspace on another monitor moves monitor focus too.
    focus_moves("eDP-1")
    if after_dispatch then after_dispatch() end
  end,
  dsp = {
    focus = function(args)
      return args
    end,
  },
}

local function turn_ends()
  while #timers > 0 do
    local pending = timers
    timers = {}
    for _, callback in ipairs(pending) do
      callback()
    end
  end
end

-- Unplug USB-2 the way Hyprland does: the warp goes to eDP-1, first in its
-- monitor list, wherever focus was.
local function unplug(opts)
  opts = opts or {}
  local was_on_it = focused == "USB-2"
  focus_moves("eDP-1", opts.assign_first)
  if was_on_it then
    -- Moving the active workspace off leaves the dying monitor a placeholder.
    handlers["workspace.active"]({ id = 2, name = "2" })
  end
  monitors["USB-2"] = nil
  handlers["monitor.removed"]({ name = "USB-2" })
  if opts.then_focus then
    focus_moves(opts.then_focus)
  end
  if opts.then_switch then
    switch_workspace(opts.then_switch)
  end
  turn_ends()
end

dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")
require("default.hypr.monitor-removal")

reset()
focus_moves("USB-2"); turn_ends()
unplug()
assert(#dispatched == 1 and dispatched[1] == "5", "the workspace you were on comes to the front of the built-in panel")

reset()
unplug()
assert(#dispatched == 0, "unplugging a display you were not on changes nothing")

reset()
focus_moves("USB-2"); turn_ends()
focus_moves("eDP-1"); turn_ends()
unplug()
assert(#dispatched == 0, "an earlier focus change does not switch the workspace later")

reset()
monitors["HDMI-A-1"] = { name = "HDMI-A-1", active = { id = 3, name = "3" } }
focus_moves("USB-2"); turn_ends()
unplug({ then_focus = "HDMI-A-1" })
assert(#dispatched == 0, "a focus change after the removal wins over the restore")

reset()
focus_moves("USB-2"); turn_ends()
unplug({ then_switch = 9 })
assert(#dispatched == 0, "a workspace switch after the removal wins over the restore")

reset()
monitors["HDMI-A-1"] = { name = "HDMI-A-1", active = { id = 7, name = "7" } }
workspaces["7"] = true
focus_moves("HDMI-A-1"); turn_ends()
unplug()
assert(#dispatched == 1 and dispatched[1] == "7", "unplugging another display leaves focus on the third one")

reset()
workspaces["5"] = nil
focus_moves("USB-2"); turn_ends()
unplug()
assert(#dispatched == 0, "an empty workspace, gone once hidden, is not recreated")

reset()
monitors["USB-2"].special = { id = -98, name = "special:scratchpad" }
focus_moves("USB-2"); turn_ends()
unplug()
assert(#dispatched == 0, "an open scratchpad is left in front")

reset()
monitors["USB-2"].active = { id = -1337, name = "notes" }
focus_moves("USB-2"); turn_ends()
unplug()
assert(#dispatched == 1 and dispatched[1] == "name:notes", "a named workspace is focused by name")

-- The restore's own focus change does not arm another one: here it leaves a
-- third monitor, which is then removed in the same turn.
reset()
monitors["HDMI-A-1"] = { name = "HDMI-A-1", active = { id = 3, name = "3" } }
workspaces["3"] = true
focus_moves("USB-2"); turn_ends()
focus_moves("eDP-1")
monitors["USB-2"] = nil
handlers["monitor.removed"]({ name = "USB-2" })
focused = "HDMI-A-1"
after_dispatch = function()
  monitors["HDMI-A-1"] = nil
  handlers["monitor.removed"]({ name = "HDMI-A-1" })
end
turn_ends()
assert(#dispatched == 1 and dispatched[1] == "5", "restoring focus does not queue a second restore")

-- A Hyprland that records focus before announcing it leaves nothing to restore
-- from, so the handler stays out of the way rather than guessing.
reset()
focus_moves("USB-2"); turn_ends()
unplug({ assign_first = true })
assert(#dispatched == 0, "a changed event order degrades to Hyprland's own behaviour")
LUA
pass "a monitor removal keeps the focused workspace in front"
