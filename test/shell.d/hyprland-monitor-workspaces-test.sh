#!/bin/bash

# Every monitor has workspaces 1-10 of its own, in a block of ten Hyprland ids
# owned by the physical monitor. Runs default/hypr/monitor-workspaces.lua against
# a small model of Hyprland's workspace handling.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua
require_command jq

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

cat >"$tmpdir/fake.lua" <<'LUA'
-- Monitors, workspaces and windows, with the parts of Hyprland's behaviour the
-- module leans on: workspaces are created on the focused monitor, moving a
-- visible workspace away leaves its monitor on another one or a fresh number,
-- focusing a workspace visible elsewhere on the current monitor swaps the two,
-- and an empty workspace nobody shows goes away.
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path

-- Neighbours map a monitor to the one in each direction, l, r, u or d.
world = { monitors = {}, workspaces = {}, windows = {}, neighbours = {}, focused = nil, active_window = nil, swaps = 0, handlers = {}, timers = {}, calls = 0 }

o = {
  bind_expressions = {},
  shell_quote = function(value) return "'" .. value .. "'" end,
}

local monitor_object, workspace_object

function monitor_named(name)
  for _, monitor in ipairs(world.monitors) do
    if monitor.name == name then return monitor end
  end
end

local function workspace_numbered(id)
  for _, workspace in ipairs(world.workspaces) do
    if workspace.id == id then return workspace end
  end
end

local function create(id, monitor)
  local workspace = { id = id, monitor = monitor }
  world.workspaces[#world.workspaces + 1] = workspace
  return workspace
end

local function activate(workspace)
  monitor_named(workspace.monitor).active = workspace.id
end

local function windows_on(id)
  local count = 0
  for _, window in pairs(world.windows) do
    if window.workspace == id then count = count + 1 end
  end
  return count
end

local function cleanup()
  local kept = {}
  for _, workspace in ipairs(world.workspaces) do
    local monitor = monitor_named(workspace.monitor)
    if windows_on(workspace.id) > 0 or (monitor and monitor.active == workspace.id) then
      kept[#kept + 1] = workspace
    end
  end
  world.workspaces = kept
end

local function lowest_free()
  local id = 1
  while workspace_numbered(id) do id = id + 1 end
  return id
end

local function move_workspace(workspace, target)
  local old = monitor_named(workspace.monitor)
  if old and old.active == workspace.id then
    local fallback
    for _, other in ipairs(world.workspaces) do
      if other.monitor == old.name and other.id ~= workspace.id then fallback = other break end
    end
    fallback = fallback or create(lowest_free(), old.name)
    old.active = fallback.id
    if world.focused == old.name then
      target.active = workspace.id
      world.focused = target.name
    end
  end
  workspace.monitor = target.name
end

function workspace_object(workspace)
  if not workspace then return nil end
  return setmetatable({}, { __index = function(_, key)
    if key == "id" then return workspace.id end
    if key == "name" then return tostring(workspace.id) end
    if key == "special" then return false end
    if key == "windows" then return windows_on(workspace.id) end
    if key == "monitor" then return monitor_object(monitor_named(workspace.monitor)) end
  end })
end

function monitor_object(monitor)
  if not monitor then return nil end
  return setmetatable({
    set_workspace = function(_, spec)
      world.calls = world.calls + 1
      local workspace = workspace_numbered(tonumber(spec.workspace))
      if workspace and workspace.monitor == monitor.name then
        monitor.active = workspace.id
        world.focused = monitor.name
      end
    end,
  }, { __index = function(_, key)
    if key == "focused" then return world.focused == monitor.name end
    if key == "active_workspace" then return workspace_object(workspace_numbered(monitor.active)) end
    if key == "is_mirror" then return false end
    return monitor[key]
  end })
end

local function resolve(id)
  local workspace = workspace_numbered(id)
  return workspace or create(id, world.focused)
end

hl = {
  on = function(name, handler) world.handlers[name] = handler end,
  dispatch = function(dispatcher)
    world.calls = world.calls + 1
    return dispatcher()
  end,
  timer = function(callback) world.timers[#world.timers + 1] = callback end,
  get_monitors = function()
    local list = {}
    for _, monitor in ipairs(world.monitors) do list[#list + 1] = monitor_object(monitor) end
    table.sort(list, function(left, right) return left.id < right.id end)
    return list
  end,
  get_monitor = function(selector)
    local neighbours = world.neighbours[world.focused] or {}
    if selector:match("^[lrud]$") then return monitor_object(monitor_named(neighbours[selector])) end
    return monitor_object(monitor_named(selector))
  end,
  get_active_monitor = function() return monitor_object(monitor_named(world.focused)) end,
  get_active_workspace = function() return workspace_object(workspace_numbered(monitor_named(world.focused).active)) end,
  get_workspace = function(id) return workspace_object(workspace_numbered(tonumber(id))) end,
  get_workspaces = function()
    local list = {}
    for _, workspace in ipairs(world.workspaces) do list[#list + 1] = workspace_object(workspace) end
    return list
  end,
  get_active_window = function()
    return world.active_window and { address = world.active_window } or nil
  end,
  get_window = function(selector)
    local address = selector:match("^address:(.+)$")
    return world.windows[address] and { address = address } or nil
  end,
  dsp = {
    focus = function(spec)
      return function()
        if spec.monitor then
          world.focused = spec.monitor
        elseif spec.window then
          local window = world.windows[spec.window:match("^address:(.+)$")]
          world.active_window = spec.window:match("^address:(.+)$")
          world.focused = workspace_numbered(window.workspace).monitor
        elseif spec.workspace then
          local workspace = resolve(tonumber(spec.workspace))
          if spec.on_current_monitor and workspace.monitor ~= world.focused then
            local away = monitor_named(workspace.monitor)
            if away.active == workspace.id then
              world.swaps = world.swaps + 1
              away.active, monitor_named(world.focused).active = monitor_named(world.focused).active, away.active
              workspace_numbered(away.active).monitor = away.name
            end
            workspace.monitor = world.focused
          end
          activate(workspace)
          world.focused = workspace.monitor
        end
        cleanup()
      end
    end,
    workspace = {
      move = function(spec)
        return function()
          local target = monitor_named(spec.monitor)
          if not target then error("Monitor not found") end
          local id = spec.workspace and tonumber(spec.workspace) or monitor_named(world.focused).active
          move_workspace(workspace_numbered(id), target)
          cleanup()
        end
      end,
      change_id = function(spec)
        return function()
          local workspace = workspace_numbered(tonumber(spec.workspace))
          local old = workspace.id
          workspace.id = spec.id
          for _, monitor in ipairs(world.monitors) do
            if monitor.active == old then monitor.active = spec.id end
          end
          for _, window in pairs(world.windows) do
            if window.workspace == old then window.workspace = spec.id end
          end
        end
      end,
    },
    window = {
      move = function(spec)
        return function()
          if spec.monitor then
            local target = monitor_named(spec.monitor)
            if not target then error("Invalid monitor / monitor doesn't exist") end
            world.windows[world.active_window].workspace = target.active
            world.focused = target.name
            cleanup()
            return
          end
          local workspace = resolve(tonumber(spec.workspace))
          world.windows[spec.window:match("^address:(.+)$")].workspace = workspace.id
          if spec.follow then
            activate(workspace)
            world.focused = workspace.monitor
          end
          cleanup()
        end
      end,
    },
  },
}

-- Run the callbacks hl.timer queued, as Hyprland's event loop does once the
-- handler that queued them has returned.
function fire_timers()
  local timers = world.timers
  world.timers = {}
  for _, callback in ipairs(timers) do callback() end
end

-- A fresh config load, as a reload or the next session gives.
function load_module()
  package.loaded["default.hypr.paths"] = nil
  package.loaded["default.hypr.global-workspaces"] = nil
  package.loaded["default.hypr.monitor-workspaces"] = nil
  return require("default.hypr.monitor-workspaces")
end

function write_config(relative, text)
  local path = os.getenv("XDG_CONFIG_HOME") .. "/" .. relative
  local dir = assert(path:match("^(.*)/"), relative)
  os.execute("mkdir -p '" .. dir:gsub("'", "'\\''") .. "'")
  local file = assert(io.open(path, "w"))
  file:write(text)
  file:close()
end

function global_flag()
  local file = io.open(os.getenv("XDG_STATE_HOME") .. "/omarchy/monitors/global-workspaces")
  local content = file and file:read("a") or ""
  if file then file:close() end
  return content
end

function plug(name, id, description, active)
  world.monitors[#world.monitors + 1] = { name = name, id = id, description = description, active = active }
  if not workspace_numbered(active) then create(active, name) end
end

function unplug(name)
  local kept = {}
  for _, monitor in ipairs(world.monitors) do
    if monitor.name ~= name then kept[#kept + 1] = monitor end
  end
  world.monitors = kept
  -- Hyprland moves the workspaces to a monitor that is still there.
  for _, workspace in ipairs(world.workspaces) do
    if workspace.monitor == name then workspace.monitor = world.monitors[1].name end
  end
  if world.focused == name then world.focused = world.monitors[1].name end
end

function window(address, id)
  if not workspace_numbered(id) then create(id, world.focused) end
  world.windows[address] = { workspace = id }
end

function on(id)
  local workspace = workspace_numbered(id)
  return workspace and workspace.monitor
end

function shows(name)
  return monitor_named(name).active
end

function state_file()
  local file = io.open(os.getenv("XDG_STATE_HOME") .. "/omarchy/monitors/workspaces")
  local content = file and file:read("a") or ""
  if file then file:close() end
  return content
end

function check(condition, message)
  if not condition then error(message, 2) end
end
LUA

run_lua() {
  local state="$tmpdir/state-$1"
  local config="$tmpdir/config-$1"
  mkdir -p "$state/omarchy" "$config"
  ROOT="$ROOT" XDG_STATE_HOME="$state" XDG_CONFIG_HOME="$config" lua -e "dofile('$tmpdir/fake.lua')" -e "$2"
}

# --- Which monitor owns which block -------------------------------------------

run_lua blocks '
plug("DP-1", 0, "LG ULTRAGEAR 111", 1)
plug("DP-2", 1, "XENEON EDGE 222", 2)
plug("eDP-1", 2, "Samsung Panel", 3)
world.focused = "DP-1"
local m = load_module()
world.handlers["hyprland.start"]()
check(m.workspace_id(hl.get_monitor("eDP-1"), 1) == 1, "the laptop panel owns the first block")
check(m.workspace_id(hl.get_monitor("DP-1"), 1) == 11, "the next monitor owns the second")
check(m.workspace_id(hl.get_monitor("DP-2"), 10) == 30, "the third monitor owns the third")
check(state_file():find("1\tDP-1\tLG ULTRAGEAR 111\n", 1, true), "the blocks are saved for the bar: " .. state_file())
' || fail "the laptop panel gets 1-10 and each other monitor the next free block"
pass "the laptop panel gets 1-10 and each other monitor the next free block"

run_lua blocks '
plug("DP-7", 0, "XENEON EDGE 222", 1)
world.focused = "DP-7"
local m = load_module()
world.handlers["hyprland.start"]()
check(m.workspace_id(hl.get_monitor("DP-7"), 1) == 21, "a monitor alone on a renamed connector got " .. m.workspace_id(hl.get_monitor("DP-7"), 1))
check(shows("DP-7") == 21, "a monitor starts on its own first workspace, not on " .. shows("DP-7"))
check(state_file():find("0\t\tSamsung Panel\n", 1, true), "an unplugged monitor keeps its block: " .. state_file())
' || fail "a monitor keeps its block across sessions and connectors"
pass "a monitor keeps its block across sessions and connectors"

# --- The keys ------------------------------------------------------------------

run_lua keys '
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 11)
world.focused = "DP-1"
local m = load_module()
world.handlers["hyprland.start"]()

hl.dispatch(m.focus(3))
check(shows("DP-1") == 13 and on(13) == "DP-1" and shows("eDP-1") == 1, "Super + 3 opens the focused monitor'"'"'s third workspace")

window("0xa", 13)
world.active_window = "0xa"
hl.dispatch(m.move_window(4, false))
check(world.windows["0xa"].workspace == 14 and on(14) == "DP-1" and shows("DP-1") == 13, "a silent move stays behind")
hl.dispatch(m.move_window(5))
check(world.windows["0xa"].workspace == 15 and shows("DP-1") == 15, "a move follows the window")

hl.dispatch(m.focus(2, "eDP-1"))
check(shows("eDP-1") == 2 and world.focused == "eDP-1", "a named monitor goes to its own workspace")

check(o.bind_expressions[m.focus(3)] == "o.workspaces.focus(3)", "the menu can replay Super + 3")
check(o.bind_expressions[m.move_window(3, false)] == "o.workspaces.move_window(3, false)", "the menu can replay a silent move")
check(o.bind_expressions[m.focus(2, "DP-1")] == "o.workspaces.focus(2, \"DP-1\")", "the bar names its monitor")
' || fail "Super + N acts on the focused monitor's own workspaces"
pass "Super + N acts on the focused monitor's own workspaces"

run_lua reclaim '
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 11)
world.focused = "DP-1"
local m = load_module()
world.handlers["hyprland.start"]()
-- An unplug left the LG'"'"'s third workspace showing on the laptop.
window("0xa", 13)
world.workspaces[#world.workspaces].monitor = "eDP-1"
monitor_named("eDP-1").active = 13

hl.dispatch(m.focus(3))
check(world.swaps == 0, "the workspaces were swapped instead of the stray one brought back")
check(shows("DP-1") == 13 and on(13) == "DP-1", "Super + 3 brings the workspace home")
check(shows("eDP-1") >= 1 and shows("eDP-1") <= 10, "the laptop falls back to one of its own, not " .. shows("eDP-1"))
' || fail "a workspace an unplug left elsewhere comes home on its key"
pass "a workspace an unplug left elsewhere comes home on its key"

# --- Monitors coming and going -------------------------------------------------

run_lua hotplug '
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 11)
world.focused = "eDP-1"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xa", 1)
world.focused = "DP-1"
window("0xb", 12)
monitor_named("DP-1").active = 12
world.focused = "eDP-1"
world.active_window = "0xa"

unplug("DP-1")
world.handlers["monitor.removed"]({ name = "DP-1" })
fire_timers()
check(world.windows["0xb"].workspace == 2 and on(2) == "eDP-1", "an unplugged monitor'"'"'s workspace joins another'"'"'s after its own, not " .. world.windows["0xb"].workspace)
check(shows("eDP-1") == 1, "the other monitor stays where it was")

hl.dispatch(hl.dsp.focus({ workspace = "2" }))
load_module()
world.handlers["config.reloaded"]()
check(shows("eDP-1") == 2 and world.windows["0xb"].workspace == 2, "a reload leaves it be")

-- The monitor comes back on another connector, and Hyprland puts it on the next free number.
plug("DP-3", 3, "LG", 3)
world.handlers["monitor.added"]({ name = "DP-3" })
check(world.windows["0xb"].workspace == 12 and on(12) == "DP-3", "the workspace goes home under its old number, not " .. world.windows["0xb"].workspace)
check(shows("DP-3") >= 11 and shows("DP-3") <= 20, "the returning monitor shows its own, not " .. shows("DP-3"))
check(on(3) == nil, "the number Hyprland gave it is left to go away")
check(shows("eDP-1") >= 1 and shows("eDP-1") <= 10, "the laptop is back on its own, not " .. shows("eDP-1"))
' || fail "an unplugged monitor's workspaces come back with it, whatever the connector"
pass "an unplugged monitor's workspaces come back with it, whatever the connector"

run_lua removed-deferred '
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 11)
world.focused = "DP-1"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xb", 11)
world.active_window = "0xb"

-- Hyprland crashes when the handler moves workspaces or focus while the
-- monitor it reports is still being torn down.
unplug("DP-1")
world.calls = 0
world.handlers["monitor.removed"]({ name = "DP-1" })
check(world.calls == 0, "the handler changed workspaces or focus during the teardown")
check(#world.timers == 1, "the handler left the reconcile for later")

fire_timers()
check(world.calls > 0 and world.windows["0xb"].workspace == 2 and on(2) == "eDP-1", "the reconcile ran once the teardown returned")
' || fail "a removed monitor is reconciled after its teardown, not during it"
pass "a removed monitor is reconciled after its teardown, not during it"

run_lua return-visible '
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 11)
plug("DP-2", 2, "XENEON", 21)
world.focused = "DP-1"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xb", 11)
world.active_window = "0xb"
unplug("DP-1")
world.handlers["monitor.removed"]({ name = "DP-1" })
fire_timers()
hl.dispatch(hl.dsp.focus({ workspace = "2" }))
check(world.windows["0xb"].workspace == 2 and shows("eDP-1") == 2, "the workspace joined the laptop'"'"'s and is in view")

plug("DP-5", 1, "LG", 3)
world.handlers["monitor.added"]({ name = "DP-5" })
check(world.swaps == 0, "the other monitor was handed the new one'"'"'s number in a swap")
check(on(11) == "DP-5" and shows("DP-5") == 11, "the returning monitor shows its first workspace again")
check(shows("eDP-1") >= 1 and shows("eDP-1") <= 10, "the other monitor is back on its own, not " .. shows("eDP-1"))
' || fail "a returning monitor takes back the workspace in view elsewhere without a swap"
pass "a returning monitor takes back the workspace in view elsewhere without a swap"

run_lua merge '
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 11)
plug("DP-2", 2, "XENEON", 21)
world.focused = "eDP-1"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xa", 1)
window("0xb", 5)
world.focused = "DP-1"
window("0xc", 11)
window("0xd", 12)
window("0xe", 13)
world.focused = "eDP-1"

unplug("DP-1")
world.handlers["monitor.removed"]({ name = "DP-1" })
fire_timers()
check(world.windows["0xc"].workspace == 6 and world.windows["0xd"].workspace == 7 and world.windows["0xe"].workspace == 8,
  "the workspaces follow the laptop'"'"'s own, in order")
check(m.workspace_id(hl.get_monitor("eDP-1"), 7) == 7, "Super + 7 reaches them")

-- Moved by hand, a workspace stays where it was put.
hl.dispatch(hl.dsp.focus({ workspace = "8" }))
world.neighbours = { ["eDP-1"] = { u = "DP-2" } }
hl.dispatch(m.move_to_monitor("u"))
check(world.windows["0xe"].workspace == 28 and on(28) == "DP-2", "the workspace joined the block above under its own slot")
local moved = world.windows["0xe"].workspace

-- A new workspace under a remembered number is not the one that went away.
world.windows["0xd"] = nil
hl.dispatch(hl.dsp.focus({ workspace = "1" }))
check(on(7) == nil, "the emptied workspace went away")
window("0xf", 7)
world.handlers["workspace.created"]({ id = 7 })

plug("DP-3", 3, "LG", 3)
world.handlers["monitor.added"]({ name = "DP-3" })
check(world.windows["0xc"].workspace == 11 and on(11) == "DP-3", "the remembered workspace went home")
check(world.windows["0xe"].workspace == moved and on(moved) == "DP-2", "the one moved by hand stayed")
check(world.windows["0xf"].workspace == 7 and on(7) == "eDP-1", "the new workspace stayed")
' || fail "an unplugged monitor's workspaces join another's after its own until it returns"
pass "an unplugged monitor's workspaces join another's after its own until it returns"

run_lua twins '
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 11)
plug("DP-2", 2, "LG", 21)
world.focused = "DP-2"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xa", 11)
window("0xb", 22)
monitor_named("DP-2").active = 22
world.focused = "eDP-1"

unplug("DP-1")
world.handlers["monitor.removed"]({ name = "DP-1" })
fire_timers()
check(m.workspace_id(hl.get_monitor("DP-2"), 1) == 21, "the remaining twin took the unplugged one'"'"'s block")
check(world.windows["0xb"].workspace == 22 and on(22) == "DP-2", "the remaining twin'"'"'s workspace moved to " .. world.windows["0xb"].workspace)
check(world.windows["0xa"].workspace == 2 and on(2) == "eDP-1", "the unplugged twin'"'"'s workspace joined the laptop'"'"'s")

m = load_module()
world.handlers["config.reloaded"]()
check(m.workspace_id(hl.get_monitor("DP-2"), 1) == 21, "a reload handed the remaining twin the other'"'"'s block")

plug("DP-3", 3, "LG", 3)
world.handlers["monitor.added"]({ name = "DP-3" })
check(world.windows["0xa"].workspace == 11 and on(11) == "DP-3", "the workspace went home to its own twin")
check(world.windows["0xb"].workspace == 22 and on(22) == "DP-2", "the other twin kept its workspace")
' || fail "a monitor keeps its block when its identical twin is unplugged"
pass "a monitor keeps its block when its identical twin is unplugged"

run_lua reused '
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 11)
plug("DP-2", 2, "XENEON", 21)
world.focused = "eDP-1"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xa", 1)
world.focused = "DP-1"
window("0xb", 12)
world.focused = "DP-2"
window("0xc", 21)
window("0xd", 22)
monitor_named("DP-2").active = 22
world.focused = "eDP-1"

unplug("DP-1")
world.handlers["monitor.removed"]({ name = "DP-1" })
fire_timers()
check(world.windows["0xb"].workspace == 2, "the workspace joined the laptop'"'"'s")
world.windows["0xb"] = nil
hl.dispatch(hl.dsp.focus({ workspace = "1" }))
check(on(2) == nil, "the emptied workspace went away")

-- Another workspace takes the number over without Hyprland creating it.
world.focused = "DP-2"
world.neighbours = { ["DP-2"] = { d = "eDP-1" } }
hl.dispatch(m.move_to_monitor("d"))
check(world.windows["0xd"].workspace == 2 and on(2) == "eDP-1", "the moved workspace took the free number")

plug("DP-3", 3, "LG", 3)
world.handlers["monitor.added"]({ name = "DP-3" })
check(world.windows["0xd"].workspace == 2 and on(2) == "eDP-1", "a stranger was sent to the returning monitor as " .. world.windows["0xd"].workspace)
' || fail "a number taken over by another workspace forgets where the old one came from"
pass "a number taken over by another workspace forgets where the old one came from"

run_lua full '
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 11)
world.focused = "eDP-1"
local m = load_module()
world.handlers["hyprland.start"]()
for slot = 1, 10 do window("0x" .. slot, slot) end
world.focused = "DP-1"
window("0xb", 12)
world.focused = "eDP-1"

unplug("DP-1")
world.handlers["monitor.removed"]({ name = "DP-1" })
fire_timers()
check(world.windows["0xb"].workspace == 12 and on(12) == "eDP-1", "with all ten taken it waits as a guest")

plug("DP-3", 3, "LG", 13)
world.handlers["monitor.added"]({ name = "DP-3" })
check(on(12) == "DP-3", "and goes home all the same")

-- A new session starts with nothing to bring back.
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3" })
fire_timers()
load_module()
world.handlers["hyprland.start"]()
local file = io.open(os.getenv("XDG_STATE_HOME") .. "/omarchy/monitors/workspaces-merged")
check(file:read("a") == "", "a new session forgot where workspaces came from")
file:close()
' || fail "a workspace with no room to join waits as a guest"
pass "a workspace with no room to join waits as a guest"

run_lua legacy '
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 2)
world.focused = "DP-1"
window("0xa", 2)
world.focused = "eDP-1"
local m = load_module()
-- A session from before workspaces were per monitor reloads its config.
world.handlers["config.reloaded"]()
check(world.windows["0xa"].workspace == 12 and on(12) == "DP-1", "the window kept its screen under its new number: " .. world.windows["0xa"].workspace)
check(shows("DP-1") == 12, "the monitor still shows it")
' || fail "a workspace on the wrong block joins its monitor's instead of jumping screens"
pass "a workspace on the wrong block joins its monitor's instead of jumping screens"

run_lua parked '
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 6)
local m = load_module()
-- A reload finds the monitor still on the empty workspace Hyprland started it on.
world.handlers["config.reloaded"]()
check(shows("DP-1") == 11, "the monitor shows its first workspace: " .. tostring(shows("DP-1")))
check(on(16) == nil, "the empty workspace was not renumbered into the block")
' || fail "a monitor parked on an empty workspace shows its own first one"
pass "a monitor parked on an empty workspace shows its own first one"

run_lua move '
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 11)
world.focused = "eDP-1"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xa", 1)
window("0xb", 2)
hl.dispatch(hl.dsp.focus({ workspace = "2" }))

hl.dispatch(m.move_to_monitor("DP-1"))
check(world.windows["0xb"].workspace == 12 and on(12) == "DP-1", "a moved workspace joins the block of its new monitor")
check(world.focused == "DP-1" and shows("DP-1") == 12, "focus goes with the workspace")
check(shows("eDP-1") == 1, "the monitor it left shows one of its own")
' || fail "moving a workspace to a monitor makes it that monitor's"
pass "moving a workspace to a monitor makes it that monitor's"

run_lua window_to_monitor '
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 11)
world.neighbours = { ["eDP-1"] = { u = "DP-1" }, ["DP-1"] = { d = "eDP-1" } }
world.focused = "eDP-1"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xa", 1)
world.active_window = "0xa"

hl.dispatch(m.move_window_to_monitor("u"))
check(world.windows["0xa"].workspace == 11, "the window lands on the workspace the monitor above shows")
check(world.focused == "DP-1", "focus goes with the window")
check(o.bind_expressions[m.move_window_to_monitor("d")] == "o.workspaces.move_window_to_monitor(\"d\")", "the menu can replay it")

-- Nothing is above the top monitor: no error, and nothing moves.
hl.dispatch(m.move_window_to_monitor("u"))
hl.dispatch(m.move_to_monitor("u"))
check(world.windows["0xa"].workspace == 11 and world.focused == "DP-1", "a move toward no monitor did something")
' || fail "a window moves to the monitor in a direction, and nowhere when there is none"
pass "a window moves to the monitor in a direction, and nowhere when there is none"

# --- Global numbers kept for an existing shortcut workflow --------------------

run_lua global-keys '
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 4)
world.focused = "eDP-1"
window("0xa", 4)
monitor_named("DP-1").active = 4
_G.omarchy_global_workspaces = true
local m = load_module()
world.handlers["config.reloaded"]()
check(world.windows["0xa"].workspace == 4 and on(4) == "DP-1", "workspace 4 stayed 4, not " .. tostring(world.windows["0xa"].workspace))
check(shows("DP-1") == 4 and shows("eDP-1") == 1, "each monitor kept the workspace it was showing")

hl.dispatch(m.focus(4))
check(world.focused == "DP-1" and shows("DP-1") == 4 and shows("eDP-1") == 1, "Super + 4 selects workspace 4 from the other monitor")
hl.dispatch(m.focus(1))
check(world.focused == "eDP-1" and shows("eDP-1") == 1, "Super + 1 selects workspace 1")

world.active_window = "0xa"
hl.dispatch(m.move_window(6, false))
check(world.windows["0xa"].workspace == 6 and shows("DP-1") == 4 and world.focused == "eDP-1", "a silent move uses the global number and stays behind")
check(global_flag() == "1\n", "the bar is told these numbers are global: [" .. global_flag() .. "]")
check(o.bind_expressions[m.focus(4)] == "o.workspaces.focus(4)", "the menu still replays Super + 4")
' || fail "Super + number keeps selecting global workspaces when that mode is on"
pass "Super + number keeps selecting global workspaces when that mode is on"

run_lua global-rule '
write_config("hypr/monitors.lua", "hl.workspace_rule({\n  workspace = \"4\",\n  monitor = \"desc:Dell Inc. DELL U2723QE\",\n})\n")
write_config("hypr/hyprland.lua", "-- hl.workspace_rule({ workspace = \"9\", monitor = \"DP-9\" })\n")
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "Dell", 4)
world.focused = "eDP-1"
window("0xa", 4)
monitor_named("DP-1").active = 4
local layouts = os.getenv("XDG_STATE_HOME") .. "/omarchy/workspace-layouts"
os.execute("mkdir -p " .. layouts)
local layout = layouts .. "/4.lua"
local file = assert(io.open(layout, "w"))
file:write("o.workspace_mode({ workspace = \"4\", mode = \"scrolling\" })\n")
file:close()

local m = load_module()
world.handlers["hyprland.start"]()
check(world.windows["0xa"].workspace == 4 and on(4) == "DP-1", "a pinned workspace 4 was renumbered to " .. tostring(world.windows["0xa"].workspace))
hl.dispatch(m.focus(4))
check(world.focused == "DP-1" and shows("eDP-1") == 1, "Super + 4 follows the workspace the rule pinned")
world.handlers["config.reloaded"]()
check(world.windows["0xa"].workspace == 4, "a reload leaves the saved layout on workspace 4")
local saved = assert(io.open(layout))
check(saved:read("a"):find("workspace = \"4\"", 1, true) ~= nil, "the saved layout file is not rewritten")
saved:close()
check(global_flag() == "1\n", "a pinned global workspace tells the bar")
' || fail "workspace rules that pin global numbers keep those shortcuts, indicators, and layouts"
pass "workspace rules that pin global numbers keep those shortcuts, indicators, and layouts"

run_lua global-keyword '
write_config("hypr/hyprland.lua", "hl.keyword(\"workspace\", \"7, monitor:HDMI-A-1, default:true\")\n")
plug("eDP-1", 0, "Panel", 1)
plug("HDMI-A-1", 1, "Portrait", 7)
world.focused = "HDMI-A-1"
window("0xa", 7)
local m = load_module()
world.handlers["config.reloaded"]()
check(world.windows["0xa"].workspace == 7 and on(7) == "HDMI-A-1", "a conf-style rule kept workspace 7, not " .. tostring(world.windows["0xa"].workspace))
' || fail "a Hyprland workspace keyword that pins a global number is kept"
pass "a Hyprland workspace keyword that pins a global number is kept"

run_lua laptop-default '
write_config("hypr/hyprland.lua", "hl.workspace_rule({ workspace = \"1\", monitor = \"eDP-1\", default = true })\n")
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 2)
world.focused = "DP-1"
window("0xa", 2)
world.focused = "eDP-1"
local m = load_module()
world.handlers["config.reloaded"]()
check(world.windows["0xa"].workspace == 12 and on(12) == "DP-1", "workspace 1 on the laptop does not freeze numbering, got " .. tostring(world.windows["0xa"].workspace))
check(global_flag() == "0\n", "the bar stays per-monitor")
' || fail "pinning workspace 1 to the laptop leaves per-monitor workspaces in place"
pass "pinning workspace 1 to the laptop leaves per-monitor workspaces in place"

run_lua block-rule '
write_config("hypr/hyprland.lua", "hl.workspace_rule({ workspace = \"12\", monitor = \"DP-1\" })\n")
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 2)
world.focused = "DP-1"
window("0xa", 2)
world.focused = "eDP-1"
local m = load_module()
world.handlers["config.reloaded"]()
check(world.windows["0xa"].workspace == 12, "a block-numbered rule still joins the monitor, got " .. tostring(world.windows["0xa"].workspace))
check(global_flag() == "0\n", "block numbers do not turn global mode on")
' || fail "rules that already use per-monitor block numbers stay on that numbering"
pass "rules that already use per-monitor block numbers stay on that numbering"

run_lua global-off '
write_config("hypr/monitors.lua", "hl.workspace_rule({ workspace = \"4\", monitor = \"DP-1\" })\n")
_G.omarchy_global_workspaces = false
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 2)
world.focused = "DP-1"
window("0xa", 2)
world.focused = "eDP-1"
local m = load_module()
world.handlers["config.reloaded"]()
check(world.windows["0xa"].workspace == 12, "opting out still renumbers, got " .. tostring(world.windows["0xa"].workspace))
check(global_flag() == "0\n", "the bar is told per-monitor won")
' || fail "omarchy_global_workspaces = false keeps per-monitor numbering"
pass "omarchy_global_workspaces = false keeps per-monitor numbering"

run_lua global-clone '
write_config("omarchy/shell.json", [[{"version":1,"bar":{"layout":{"left":[{"id":"me.workspaces"}]}}}]])
write_config("omarchy/plugins/me.workspaces/manifest.json", [[{"schemaVersion":1,"id":"me.workspaces","name":"Workspaces","version":"1.0.0","kinds":["bar-widget"],"entryPoints":{"barWidget":"Workspaces.qml"},"omarchy":{"clonedFrom":"omarchy.workspaces"}}]])
write_config("omarchy/plugins/me.workspaces/Workspaces.qml", "readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData\ntext: focused ? glyph : (modelData === 10 ? \"0\" : String(modelData))\n")
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 4)
world.focused = "eDP-1"
window("0xa", 4)
monitor_named("DP-1").active = 4
local m = load_module()
world.handlers["hyprland.start"]()
check(world.windows["0xa"].workspace == 4, "an older cloned indicator lost workspace 4, now " .. tostring(world.windows["0xa"].workspace))
hl.dispatch(m.focus(4))
check(world.focused == "DP-1" and shows("DP-1") == 4, "Super + 4 still matches the number the clone draws")
' || fail "an older cloned workspace indicator keeps the workspace ids it compares"
pass "an older cloned workspace indicator keeps the workspace ids it compares"

run_lua updated-clone '
write_config("omarchy/shell.json", [[{"version":1,"bar":{"layout":{"left":[{"id":"me.workspaces"}]}}}]])
write_config("omarchy/plugins/me.workspaces/manifest.json", [[{"schemaVersion":1,"id":"me.workspaces","name":"Workspaces","version":"1.0.0","kinds":["bar-widget"],"entryPoints":{"barWidget":"Workspaces.qml"},"omarchy":{"clonedFrom":"omarchy.workspaces"}}]])
write_config("omarchy/plugins/me.workspaces/Unused.qml", [[Hyprland.focusedWorkspace.id === modelData; String(modelData)]])
write_config("omarchy/plugins/me.workspaces/Workspaces.qml", "readonly property bool shown: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData\nfunction slotOf(id) { return id }\ntext: String(slot)\n")
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 2)
world.focused = "DP-1"
window("0xa", 2)
world.focused = "eDP-1"
local m = load_module()
world.handlers["config.reloaded"]()
check(world.windows["0xa"].workspace == 12, "a clone that already uses slots was kept global, got " .. tostring(world.windows["0xa"].workspace))
check(global_flag() == "0\n", "the bar stays per-monitor for a slot-based clone")
' || fail "a cloned indicator that already understands slots keeps per-monitor numbers"
pass "a cloned indicator that already understands slots keeps per-monitor numbers"

run_lua global-move '
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 11)
world.neighbours = { ["eDP-1"] = { r = "DP-1" }, ["DP-1"] = { l = "eDP-1" } }
world.focused = "eDP-1"
_G.omarchy_global_workspaces = true
local m = load_module()
world.handlers["hyprland.start"]()
window("0xa", 2)
hl.dispatch(hl.dsp.focus({ workspace = "2" }))
hl.dispatch(m.move_to_monitor("r"))
check(world.windows["0xa"].workspace == 2 and on(2) == "DP-1", "moving to the monitor on the right kept number 2, not " .. tostring(world.windows["0xa"].workspace))
' || fail "moving a workspace to another monitor keeps its number in global mode"
pass "moving a workspace to another monitor keeps its number in global mode"

# Exercise the reusable detector directly, without running the migration.
run_lua detector-comments '
local rule = [[hl.workspace_rule({ workspace = "4", monitor = "DP-1" })]]
local cases = {
  { "-- " .. rule, false },
  { "--[[\n" .. rule .. "\n]]", false },
  { "--[==[\n" .. rule .. "\n]]\n]==]", false },
  { "--[[" .. rule, false },
  { "--[[ignored]] " .. rule, true },
  { [[hl.workspace_rule({ workspace = "4", monitor = "desc:Dell -- Desk" })]], true },
  { [[local label = "escaped \" -- marker"; ]] .. rule, true },
  { [==[local label = [=[--[[not a comment]]=]; ]==] .. rule, true },
  { [[hl.keyword("workspace", "7, monitor:HDMI-A-1") -- trailing]], true },
}
for index, case in ipairs(cases) do
  write_config("hypr/hyprland.lua", case[1])
  package.loaded["default.hypr.global-workspaces"] = nil
  check(require("default.hypr.global-workspaces").detected() == case[2], "comment/quote case " .. index)
end
' || fail "disabled Lua rules are ignored while quoted comment markers stay intact"
pass "disabled Lua rules are ignored while quoted comment markers stay intact"

run_lua detector-clones '
local legacy = [[Hyprland.focusedWorkspace.id === modelData; text: String(modelData)]]
local manifest = [[{"schemaVersion":1,"id":"me.workspaces","name":"Workspaces","version":"1.0.0","kinds":["bar-widget"],"entryPoints":{"barWidget":"Workspaces.qml"},"omarchy":{"clonedFrom":"omarchy.workspaces"}}]]
write_config("omarchy/plugins/me.workspaces/manifest.json", manifest)
write_config("omarchy/plugins/me.workspaces/Workspaces.qml", legacy)
write_config("omarchy/plugins/.me.workspaces.bak/manifest.json", [[{"schemaVersion":1,"id":"me.workspaces","name":"Workspaces","version":"1.0.0","kinds":["bar-widget"],"entryPoints":{"barWidget":"Workspaces.qml"},"omarchy":{"clonedFrom":"omarchy.workspaces"}}]])
write_config("omarchy/plugins/.me.workspaces.bak/Workspaces.qml", legacy)
write_config("omarchy/plugins/me.bar/manifest.json", [[{"schemaVersion":1,"id":"me.bar","name":"Bar","version":"1.0.0","kinds":["bar"],"entryPoints":{"bar":"Bar.qml"},"omarchy":{"clonedFrom":"omarchy.bar"}}]])
write_config("omarchy/plugins/me.bar/widgets/Workspaces.qml", legacy)
local cases = {
  { [[{"version":1}]], false },
  { [[{"version":1,"bar":{"layout":{"left":[{"id":"omarchy.workspaces"}]}}}]], false },
  { [[{"version":1,"bar":{"layout":{"left":[{"id":"me.workspaces"}]}},"disabledPlugins":["me.workspaces"]}]], false },
  { [[{"version":1,"bar":{"layout":{"left":[{"id":".me.workspaces.bak"}]}}}]], false },
  { [[{"version":1,"bar":{"layout":{"left":[{"id":"me.workspaces"}]}}}]], true },
  { [[{"version":1,"bar":{"layout":{"right":["me.workspaces"]}}}]], true },
  { [[{"version":1,"bar":{"layout":{"tray":[{"id":"me.workspaces"}]}}}]], true },
  { [[{"version":1,"bar":{"id":"me.bar","layout":{"left":[]}}}]], false },
  { [[{"bar":{"layout":{"left":[{"id":"me.workspaces"}]}}}]], false },
  { [[not json]], false },
}
for index, case in ipairs(cases) do
  write_config("omarchy/shell.json", case[1])
  package.loaded["default.hypr.global-workspaces"] = nil
  check(require("default.hypr.global-workspaces").detected() == case[2], "active clone case " .. index)
end
write_config("omarchy/shell.json", [[{"version":1,"bar":{"layout":{"left":[{"id":"me.workspaces"}]}}}]])
local invalid_manifests = {
  (manifest:gsub([=[%["bar%-widget"%]]=], [=["bar-widget"]=])),
  (manifest:gsub([=["barWidget":"Workspaces.qml"]=], [=["barWidget":"Workspaces.qml","service":"../unsafe.qml"]=])),
}
for index, invalid in ipairs(invalid_manifests) do
  write_config("omarchy/plugins/me.workspaces/manifest.json", invalid)
  package.loaded["default.hypr.global-workspaces"] = nil
  check(not require("default.hypr.global-workspaces").detected(), "invalid manifest case " .. index)
end
' || fail "only selected, enabled workspace clone entrypoints can keep global ids"
pass "only selected, enabled workspace clone entrypoints can keep global ids"

run_node_test <<'JS'
// Execute the widget functions with detached Hyprland data and a command sink.
const source = require('fs').readFileSync(path.join(root, 'shell/plugins/bar/widgets/Workspaces.qml'), 'utf8')
const hyprland = { focusedWorkspace: { id: 4 }, workspaces: { values: [{ id: 4 }, { id: 11 }, { id: 27 }, { id: 11 }, { id: -99 }, { id: 0 }] } }
const calls = []
const widget = { globalWorkspaces: true, slots: 10, block: 1, monitorName: 'DP-1', monitor: { focused: false, activeWorkspace: { id: 11 } }, bar: { run: command => calls.push(command) } }
const util = { shellQuote: text => "'" + text + "'" }
for (const name of ['activeWorkspaceId', 'currentId', 'blockOf', 'slotOf', 'globalWorkspaceIds', 'workspaceIds', 'cycleLayout', 'focusWorkspace']) {
  const match = source.match(new RegExp(`\\n  function ${name}\\([^)]*\\) \\{([\\s\\S]*?)\\n  \\}`))
  if (!match) fail('workspace widget function is available', name)
  const fn = new Function('root', 'Hyprland', 'Util', 'id', match[1])
  widget[name] = id => fn(widget, hyprland, util, id)
}
widget.dispatch = expression => calls.push(expression)
assertDeepEqual(widget.workspaceIds(), [1, 2, 3, 4, 5, 11, 27], 'global bars keep all existing positive workspace ids, once and in order')
assertEqual(widget.currentId(), 4, 'a global bar shows the focused workspace on another monitor')
widget.cycleLayout()
assertEqual(calls.pop(), 'omarchy-hyprland-workspace-layout-toggle', 'a global glyph cycles the shown workspace without focusing the clicked monitor')
widget.focusWorkspace(27)
assertEqual(calls.pop(), 'hl.dsp.focus({ workspace = "27" })', 'an existing global workspace above ten can be selected')
widget.globalWorkspaces = false
assertEqual(widget.currentId(), 11, 'a per-monitor bar still follows its own monitor')
assertDeepEqual(widget.workspaceIds(), [11, 12, 13, 14, 15], 'a per-monitor bar retains its own block')
widget.cycleLayout()
assert(calls.pop().startsWith('hyprctl dispatch '), 'a per-monitor glyph still focuses its monitor before toggling')
JS
