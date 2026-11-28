#!/bin/bash

# Every monitor has workspaces 1-10 of its own, in a block of ten Hyprland ids
# owned by the physical monitor. Runs default/hypr/monitor-workspaces.lua against
# a small model of Hyprland's workspace handling.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

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
  local monitor = monitor_named(workspace.monitor)
  assert(monitor, "Workspace has no monitor")
  monitor.active = workspace.id
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
    -- Persistent workspaces survive with no windows, as Hyprland keeps them.
    if workspace.is_persistent or windows_on(workspace.id) > 0 or (monitor and monitor.active == workspace.id) then
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
    if world.handlers["workspace.active"] then
      world.handlers["workspace.active"](workspace_object(fallback))
    end
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
    if key == "is_persistent" then return workspace.is_persistent or false end
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
    local address = world.active_window
    local window = address and world.windows[address]
    if not window then return nil end
    return { address = address, workspace = { id = window.workspace } }
  end,
  get_window = function(selector)
    local address = selector:match("^address:(.+)$")
    local window = address and world.windows[address]
    if not window then return nil end
    return { address = address, workspace = { id = window.workspace } }
  end,
  dsp = {
    focus = function(spec)
      return function()
        if spec.monitor then
          world.focused = spec.monitor
        elseif spec.window then
          local address = spec.window:match("^address:(.+)$")
          local window = world.windows[address]
          world.active_window = address
          local workspace = window and workspace_numbered(window.workspace)
          if workspace then
            activate(workspace)
            world.focused = workspace.monitor
          end
        elseif spec.workspace then
          local target_id = tonumber(spec.workspace)
          if not target_id and (spec.workspace == "m+1" or spec.workspace == "m-1") then
            local mon = monitor_named(world.focused)
            local ids = {}
            for _, w in ipairs(world.workspaces) do
              if w.monitor == mon.name then ids[#ids + 1] = w.id end
            end
            table.sort(ids)
            local pos = 1
            for idx, id in ipairs(ids) do
              if id == mon.active then pos = idx break end
            end
            local step = spec.workspace == "m+1" and 1 or -1
            target_id = ids[((pos - 1 + step) % #ids) + 1]
          end
          local workspace = resolve(target_id)
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
          local target_id = tonumber(spec.workspace)
          if not target_id and (spec.workspace == "r-1" or spec.workspace == "r+1") then
            local mon = monitor_named(world.focused)
            target_id = mon.active + (spec.workspace == "r+1" and 1 or -1)
          end
          local workspace = resolve(target_id)
          local addr = spec.window and spec.window:match("^address:(.+)$") or world.active_window
          world.windows[addr].workspace = workspace.id
          if spec.follow ~= false then
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
  package.loaded["default.hypr.monitor-workspaces"] = nil
  return require("default.hypr.monitor-workspaces")
end

function plug(name, id, description, active)
  -- A real monitor replacing FALLBACK takes the workspaces that were waiting
  -- there, and Hyprland starts it on `active`, the lowest free number.
  local fallback = monitor_named("FALLBACK")
  if fallback then
    local kept = {}
    for _, monitor in ipairs(world.monitors) do
      if monitor.name ~= "FALLBACK" then kept[#kept + 1] = monitor end
    end
    world.monitors = kept
  end
  world.monitors[#world.monitors + 1] = { name = name, id = id, description = description, active = active }
  if not workspace_numbered(active) then create(active, name) end
  if fallback then
    for _, workspace in ipairs(world.workspaces) do
      if workspace.monitor == "FALLBACK" then workspace.monitor = name end
    end
    if world.focused == "FALLBACK" then world.focused = name end
  end
end

function unplug(name)
  local kept = {}
  for _, monitor in ipairs(world.monitors) do
    if monitor.name ~= name then kept[#kept + 1] = monitor end
  end
  world.monitors = kept
  -- Hyprland moves the workspaces to a monitor that is still there, or onto
  -- its FALLBACK placeholder when the last one is unplugged.
  local target
  if #world.monitors == 0 then
    target = "FALLBACK"
    world.monitors[1] = { name = "FALLBACK", id = 0, description = "", active = nil }
  else
    target = world.monitors[1].name
  end
  for _, workspace in ipairs(world.workspaces) do
    if workspace.monitor == name then workspace.monitor = target end
  end
  if world.focused == name or target == "FALLBACK" then world.focused = target end
end

-- The lowest workspace id Hyprland would give a monitor it is adding.
function free_id()
  local id = 1
  while workspace_numbered(id) do id = id + 1 end
  return id
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
  mkdir -p "$state/omarchy"
  ROOT="$ROOT" XDG_STATE_HOME="$state" lua -e "dofile('$tmpdir/fake.lua')" -e "$2"
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
check(state_file():find("0\t\tSamsung Panel\t", 1, true), "an unplugged monitor keeps its block: " .. state_file())
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

run_lua reclaim_monitorless '
plug("DP-1", 0, "Dell", 1)
world.focused = "DP-1"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xa", 2)
world.workspaces[#world.workspaces].monitor = nil

hl.dispatch(m.focus(2))
check(shows("DP-1") == 2 and on(2) == "DP-1", "Super + 2 brings a monitorless workspace home")
check(world.windows["0xa"].workspace == 2, "the orphaned window keeps its workspace")

window("0xb", 3)
world.workspaces[#world.workspaces].monitor = nil
world.active_window = "0xa"
hl.dispatch(m.move_window(3))
check(shows("DP-1") == 3 and on(3) == "DP-1", "moving a window reclaims a monitorless destination")
check(world.windows["0xa"].workspace == 3 and world.windows["0xb"].workspace == 3, "both windows stay reachable")
' || fail "workspace actions reclaim a workspace left without a monitor"
pass "workspace actions reclaim a workspace left without a monitor"

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

# --- A KVM switch drops every monitor, then brings them back ---------------------

run_lua kvm '
plug("DP-3", 0, "Samsung LS27CG51x", 1)
plug("HDMI-A-1", 1, "Samsung LS27CG51x", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(2))
window("0xa", 2)
world.focused = "HDMI-A-1"
window("0xb", 11)
hl.dispatch(hl.dsp.focus({ workspace = "11" }))
local dp = shows("DP-3")
local hdmi = shows("HDMI-A-1")

-- DP-3 drops first, so its workspace joins HDMI-A-1, then that one goes too.
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = dp } })
fire_timers()
unplug("HDMI-A-1")
world.handlers["monitor.removed"]({ name = "HDMI-A-1", active_workspace = { id = hdmi } })
fire_timers()
check(not state_file():find("FALLBACK", 1, true), "FALLBACK took a block: " .. state_file())

plug("DP-3", 0, "Samsung LS27CG51x", free_id())
world.handlers["monitor.added"]({ name = "DP-3" })
check(shows("DP-3") == 2, "DP-3 came back on " .. shows("DP-3") .. " instead of workspace 2")
check(world.windows["0xa"].workspace == 2 and on(2) == "DP-3", "its window is on " .. world.windows["0xa"].workspace)
check(on(1) == nil, "the empty workspace Hyprland started it on was kept")

plug("HDMI-A-1", 1, "Samsung LS27CG51x", free_id())
world.handlers["monitor.added"]({ name = "HDMI-A-1" })
check(shows("HDMI-A-1") == 11, "HDMI-A-1 came back on " .. shows("HDMI-A-1"))
check(world.windows["0xb"].workspace == 11 and on(11) == "HDMI-A-1", "its window is on " .. world.windows["0xb"].workspace)
check(shows("DP-3") == 2, "bringing HDMI-A-1 back moved DP-3 to " .. shows("DP-3"))
' || fail "a KVM switch brings each monitor back on the workspace it was showing"
pass "a KVM switch brings each monitor back on the workspace it was showing"

run_lua kvm-reload '
plug("DP-3", 0, "Samsung LS27CG51x", 1)
plug("HDMI-A-1", 1, "Samsung LS27CG51x", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(2))
window("0xa", 2)
world.focused = "HDMI-A-1"
window("0xb", 11)
hl.dispatch(hl.dsp.focus({ workspace = "11" }))
local dp = shows("DP-3")
local hdmi = shows("HDMI-A-1")

unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = dp } })
fire_timers()
unplug("HDMI-A-1")
world.handlers["monitor.removed"]({ name = "HDMI-A-1", active_workspace = { id = hdmi } })
fire_timers()

-- A reload while nothing is plugged in, then both come back with the config.
load_module()
world.handlers["config.reloaded"]()
plug("DP-3", 0, "Samsung LS27CG51x", free_id())
plug("HDMI-A-1", 1, "Samsung LS27CG51x", free_id())
world.handlers["config.reloaded"]()
check(shows("DP-3") == 2, "DP-3 came back on " .. shows("DP-3") .. " after a reload")
check(world.windows["0xa"].workspace == 2 and on(2) == "DP-3", "its window is on " .. world.windows["0xa"].workspace)
check(shows("HDMI-A-1") == 11, "HDMI-A-1 came back on " .. shows("HDMI-A-1") .. " after a reload")
check(world.windows["0xb"].workspace == 11 and on(11) == "HDMI-A-1", "its window is on " .. world.windows["0xb"].workspace)
check(not state_file():find("FALLBACK", 1, true), "a reload gave FALLBACK a block: " .. state_file())
' || fail "a reload between unplug and return still restores the workspace each monitor was showing"
pass "a reload between unplug and return still restores the workspace each monitor was showing"

run_lua single '
plug("DP-3", 0, "LG", 1)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(5))
window("0xa", 5)
local dp = shows("DP-3")

unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = dp } })
fire_timers()
check(monitor_named("FALLBACK"), "unplugging the only monitor left no FALLBACK")
check(not state_file():find("FALLBACK", 1, true), "the only monitor leaving FALLBACK behind gave it a block: " .. state_file())

plug("DP-3", 0, "LG", free_id())
world.handlers["monitor.added"]({ name = "DP-3" })
check(shows("DP-3") == 5, "the only monitor came back on " .. shows("DP-3"))
check(world.windows["0xa"].workspace == 5 and on(5) == "DP-3", "its window is on " .. world.windows["0xa"].workspace)
check(not monitor_named("FALLBACK"), "FALLBACK was still there after the monitor returned")
' || fail "unplugging the only monitor and plugging it back shows the workspace it was showing"
pass "unplugging the only monitor and plugging it back shows the workspace it was showing"

run_lua shown-first '
plug("DP-3", 0, "LG", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xa", 1)
hl.dispatch(hl.dsp.focus({ workspace = "1" }))
world.focused = "HDMI-A-1"
window("0xb", 11)

unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = 1 } })
fire_timers()

plug("DP-3", 3, "LG", free_id())
world.handlers["monitor.added"]({ name = "DP-3" })
check(shows("DP-3") == 1, "a monitor that was on its first workspace came back on " .. shows("DP-3"))
check(world.windows["0xa"].workspace == 1 and on(1) == "DP-3", "the window is on " .. world.windows["0xa"].workspace .. " instead of workspace 1")
check(shows("HDMI-A-1") == 11, "the monitor that stayed was moved to " .. shows("HDMI-A-1"))
' || fail "a monitor showing its first workspace gets that workspace back, not an empty one under the same number"
pass "a monitor showing its first workspace gets that workspace back, not an empty one under the same number"

run_lua shown-emptied '
plug("DP-3", 0, "LG", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(2))
window("0xa", 2)
hl.dispatch(m.focus(4))
window("0xb", 4)
hl.dispatch(m.focus(2))
local dp = shows("DP-3")

unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = dp } })
fire_timers()

-- The workspace it was showing is closed while it is away.
world.windows["0xa"] = nil
hl.dispatch(hl.dsp.focus({ workspace = "11" }))

plug("DP-3", 3, "LG", free_id())
world.handlers["monitor.added"]({ name = "DP-3" })
check(on(world.windows["0xb"].workspace) == "DP-3", "the remaining window came home to " .. tostring(on(world.windows["0xb"].workspace)))
check(shows("DP-3") == world.windows["0xb"].workspace, "it came back on empty workspace " .. shows("DP-3") .. " while a window waited on " .. world.windows["0xb"].workspace)
check(shows("HDMI-A-1") == 11, "the other monitor was moved to " .. shows("HDMI-A-1"))
' || fail "a returning monitor whose shown workspace was emptied shows one that still has windows"
pass "a returning monitor whose shown workspace was emptied shows one that still has windows"

run_lua shown-moved '
plug("eDP-1", 0, "Panel", 1)
plug("DP-1", 1, "LG", 11)
plug("HDMI-A-1", 2, "Dell", 21)
world.focused = "eDP-1"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(2))
window("0xa", 2)
hl.dispatch(m.focus(4))
window("0xb", 4)
hl.dispatch(m.focus(2))
local panel = shows("eDP-1")

unplug("eDP-1")
world.handlers["monitor.removed"]({ name = "eDP-1", active_workspace = { id = panel } })
fire_timers()

local moved = world.windows["0xa"].workspace
hl.dispatch(hl.dsp.focus({ workspace = tostring(moved) }))
world.neighbours = { ["DP-1"] = { r = "HDMI-A-1" }, ["HDMI-A-1"] = { l = "DP-1" } }
hl.dispatch(m.move_to_monitor("r"))
check(on(world.windows["0xa"].workspace) == "HDMI-A-1", "the shown workspace was not moved by hand")

plug("eDP-1", 0, "Panel", free_id())
world.handlers["monitor.added"]({ name = "eDP-1" })
check(on(world.windows["0xa"].workspace) == "HDMI-A-1", "the workspace moved by hand came back")
check(on(world.windows["0xb"].workspace) == "eDP-1", "the other window came home to " .. tostring(on(world.windows["0xb"].workspace)))
check(shows("eDP-1") == world.windows["0xb"].workspace, "the panel came back on " .. shows("eDP-1") .. " instead of the workspace that still has its window")
' || fail "a returning monitor does not take back a workspace that was moved by hand, and does not stay on an empty one"
pass "a returning monitor does not take back a workspace that was moved by hand, and does not stay on an empty one"

# A full disk makes close() fail after open("w") has already truncated the file.
# The previous record has to stay put, and the next save has to try again.
run_lua shown-write-retry '
plug("DP-3", 0, "LG", 1)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(2))
window("0xa", 2)
world.handlers["config.reloaded"]()

local shown_path = os.getenv("XDG_STATE_HOME") .. "/omarchy/monitors/workspaces-shown"
local function read_shown()
  local file = io.open(shown_path)
  local content = file and file:read("a") or ""
  if file then file:close() end
  return content
end
local before = read_shown()
check(before:find("2\t0\tLG\n", 1, true), "workspace 2 was not saved: " .. before:gsub("\n", "\\n"))

local real_open = io.open
local fail_close = true
io.open = function(path, mode)
  local file, err = real_open(path, mode)
  if not file or not fail_close or mode ~= "w" or not tostring(path):find("workspaces-shown", 1, true) then
    return file, err
  end
  return {
    write = function(self)
      return self
    end,
    close = function()
      file:close()
      return nil, "No space left on device"
    end,
  }
end

hl.dispatch(m.focus(4))
world.handlers["config.reloaded"]()
local during = read_shown()
check(during == before, "a failed close replaced the shown file with " .. during:gsub("\n", "\\n"))

local pipe = io.popen("ls -a " .. os.getenv("XDG_STATE_HOME") .. "/omarchy/monitors")
local listing = pipe:read("a")
pipe:close()
check(not listing:find(".tmp", 1, true), "a temp file was left after the failed close: " .. listing)

fail_close = false
io.open = real_open
world.handlers["config.reloaded"]()
local after = read_shown()
check(after:find("4\t0\tLG\n", 1, true), "retry did not persist workspace 4: " .. after:gsub("\n", "\\n"))
' || fail "a failed shown-workspace write keeps the previous file and retries"
pass "a failed shown-workspace write keeps the previous file and retries"

# Monitor 1 is on 10. Monitor 2's 11 and 12 join it as 1 and 2. Closing the
# window that came from 12 removes workspace 2, but its merged record remains.
# The returning monitor starts on empty 11, and parking that empty workspace
# on 2 must not drop the unvisited record.
run_lua reclaim-park '
plug("DP-1", 0, "LG", 10)
plug("DP-2", 1, "Dell", 11)
world.focused = "DP-2"
window("0xa", 11)
window("0xb", 12)
world.focused = "DP-1"
local m = load_module()
world.handlers["hyprland.start"]()
check(shows("DP-1") == 10, "monitor 1 started on " .. tostring(shows("DP-1")))

unplug("DP-2")
world.handlers["monitor.removed"]({ name = "DP-2" })
fire_timers()
check(world.windows["0xa"].workspace == 1 and world.windows["0xb"].workspace == 2,
  "11 and 12 merged to " .. world.windows["0xa"].workspace .. " and " .. world.windows["0xb"].workspace)

world.windows["0xb"] = nil
hl.dispatch(hl.dsp.focus({ workspace = "10" }))
check(on(2) == nil, "the closed workspace was kept at " .. tostring(on(2)))
check(shows("DP-1") == 10, "monitor 1 left workspace 10 for " .. tostring(shows("DP-1")))

plug("DP-2", 1, "Dell", 11)
world.handlers["monitor.added"]({ name = "DP-2" })
check(world.windows["0xa"].workspace == 11 and on(11) == "DP-2",
  "original workspace 11 came back as " .. world.windows["0xa"].workspace .. " on " .. tostring(on(world.windows["0xa"].workspace)))
check(shows("DP-2") == 11, "the returning monitor shows " .. tostring(shows("DP-2")))
check(shows("DP-1") == 10, "monitor 1 was moved to " .. tostring(shows("DP-1")))
' || fail "reclaiming a workspace number does not drop the next merged workspace"
pass "reclaiming a workspace number does not drop the next merged workspace"

# Two monitors with one description, Twin on DP-3 and Twin #2 on HDMI-A-1.
# Unplugging HDMI first and bringing it back first must not hand it Twin.
run_lua twin-order '
plug("DP-3", 0, "Twin", 1)
plug("HDMI-A-1", 1, "Twin", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(2))
window("0xa", 2)
world.focused = "HDMI-A-1"
hl.dispatch(hl.dsp.focus({ workspace = "12" }))
window("0xb", 12)

unplug("HDMI-A-1")
world.handlers["monitor.removed"]({ name = "HDMI-A-1", active_workspace = { id = 12 } })
fire_timers()
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = 2 } })
fire_timers()

plug("HDMI-A-1", 1, "Twin", free_id())
world.handlers["monitor.added"]({ name = "HDMI-A-1" })
check(shows("HDMI-A-1") == 12, "HDMI-A-1 came back on " .. tostring(shows("HDMI-A-1")) .. " instead of workspace 12")
check(world.windows["0xb"].workspace == 12 and on(12) == "HDMI-A-1",
  "HDMI-A-1'"'"'s window is on " .. world.windows["0xb"].workspace .. " at " .. tostring(on(world.windows["0xb"].workspace)))
check(on(2) ~= "HDMI-A-1", "HDMI-A-1 took the other monitor'"'"'s workspace")

plug("DP-3", 0, "Twin", free_id())
world.handlers["monitor.added"]({ name = "DP-3" })
check(shows("DP-3") == 2, "DP-3 came back on " .. tostring(shows("DP-3")) .. " instead of workspace 2")
check(world.windows["0xa"].workspace == 2 and on(2) == "DP-3",
  "DP-3'"'"'s window is on " .. world.windows["0xa"].workspace .. " at " .. tostring(on(world.windows["0xa"].workspace)))
check(shows("HDMI-A-1") == 12, "bringing DP-3 back moved HDMI-A-1 to " .. tostring(shows("HDMI-A-1")))
' || fail "identical monitors keep their own workspaces when they return in reverse order"
pass "identical monitors keep their own workspaces when they return in reverse order"

# DP-3 was showing 2, and also had workspace 4. While it is unplugged the
# remaining monitor is left viewing 4. The return shows 2 again, and that
# clears the away record: a later switch to an empty workspace survives a reload.
run_lua stale-away '
plug("DP-3", 0, "LG", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(2))
window("0xa", 2)
hl.dispatch(m.focus(4))
window("0xb", 4)
hl.dispatch(m.focus(2))

unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = 2 } })
fire_timers()

local viewed = world.windows["0xb"].workspace
hl.dispatch(hl.dsp.focus({ workspace = tostring(viewed) }))
world.active_window = "0xb"

plug("DP-3", 3, "LG", free_id())
world.handlers["monitor.added"]({ name = "DP-3" })
check(shows("DP-3") == 2, "DP-3 came back on " .. tostring(shows("DP-3")) .. " instead of workspace 2")
check(world.windows["0xa"].workspace == 2 and on(2) == "DP-3",
  "workspace 2 is on " .. tostring(on(world.windows["0xa"].workspace)))
check(world.windows["0xb"].workspace == 4 and on(4) == "DP-3",
  "workspace 4 is on " .. tostring(on(world.windows["0xb"].workspace)))

hl.dispatch(m.focus(7, "DP-3"))
check(shows("DP-3") == 7, "DP-3 did not switch to the empty workspace, it shows " .. tostring(shows("DP-3")))
load_module()
world.handlers["config.reloaded"]()
check(shows("DP-3") == 7, "a reload put DP-3 back on " .. tostring(shows("DP-3")))
' || fail "a returning monitor shows the workspace it left, then stays on an empty one"
pass "a returning monitor shows the workspace it left, then stays on an empty one"

# workspace.active carries the workspace, whose monitor may not be the focused one.
run_lua unfocused-switch '
plug("DP-3", 0, "LG", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "HDMI-A-1"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xh", 11)

world.focused = "DP-3"
window("0xa", 4)
monitor_named("DP-3").active = 4
world.focused = "HDMI-A-1"
world.handlers["workspace.active"](hl.get_workspace(4))
fire_timers()

local file = io.open(os.getenv("XDG_STATE_HOME") .. "/omarchy/monitors/workspaces-shown")
local content = file:read("a")
file:close()
check(content:find("4\t0\tLG\n", 1, true), "DP-3'"'"'s switch was recorded as " .. content:gsub("\n", "\\n"))
check(content:find("11\t0\tDell\n", 1, true), "the focused monitor'"'"'s workspace changed: " .. content:gsub("\n", "\\n"))

unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3" })
fire_timers()
plug("DP-3", 3, "LG", free_id())
world.handlers["monitor.added"]({ name = "DP-3" })
check(shows("DP-3") == 4, "DP-3 came back on " .. tostring(shows("DP-3")) .. " instead of workspace 4")
check(shows("HDMI-A-1") == 11, "HDMI-A-1 was moved to " .. tostring(shows("HDMI-A-1")))
' || fail "a workspace switch on a monitor that is not focused is remembered for that monitor"
pass "a workspace switch on a monitor that is not focused is remembered for that monitor"

# Hyprland 0.56.2, while unplugging, activates another workspace on the departing
# monitor and emits workspace.active BEFORE moving the active workspace away
# (WorkspacePlacementController.cpp:288-296), then clears active_workspace, and
# only then emits monitor.removed. The monitor was showing 4; 2 is that migration.
run_lua unplug-migration '
plug("DP-3", 0, "LG", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(2))
window("0xb", 2)
hl.dispatch(m.focus(4))
window("0xa", 4)
world.handlers["config.reloaded"]()
check(shows("DP-3") == 4, "DP-3 was showing " .. tostring(shows("DP-3")))

-- Exact Hyprland 0.56.2 disconnect order: activate 2 and emit workspace.active
-- while workspace 4 is still on DP-3, then move 4 onto HDMI-A-1, clear active,
-- and emit monitor.removed before timers fire.
monitor_named("DP-3").active = 2
world.handlers["workspace.active"](hl.get_workspace(2))
for _, workspace in ipairs(world.workspaces) do
  if workspace.id == 4 then workspace.monitor = "HDMI-A-1" end
end
monitor_named("DP-3").active = nil
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3" })
fire_timers()

plug("DP-3", 3, "LG", free_id())
world.handlers["monitor.added"]({ name = "DP-3" })
check(shows("DP-3") == 4, "DP-3 came back on " .. tostring(shows("DP-3")) .. " instead of workspace 4")
check(world.windows["0xa"].workspace == 4 and on(4) == "DP-3",
  "the window from workspace 4 is on " .. world.windows["0xa"].workspace .. " at " .. tostring(on(world.windows["0xa"].workspace)))
check(shows("HDMI-A-1") == 11, "HDMI-A-1 was moved to " .. tostring(shows("HDMI-A-1")))
' || fail "unplugging does not replace the shown workspace with the one Hyprland activates while migrating"
pass "unplugging does not replace the shown workspace with the one Hyprland activates while migrating"

# DP-3 switches from 1 to 4 via Omarchy focus, and monitor.removed runs before
# workspace.active'"'"'s timer, with Hyprland activating 1 to plug the gap and then
# clearing active_workspace. DP-3 must still come back on 4.
run_lua switch-races-removal '
plug("DP-3", 0, "LG", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xa", 1)
window("0xb", 4)
world.handlers["config.reloaded"]()
check(shows("DP-3") == 1, "DP-3 was showing " .. tostring(shows("DP-3")))

hl.dispatch(m.focus(4))
world.handlers["workspace.active"](hl.get_workspace(4))
-- Unplug races immediately before the timer, with Hyprland activating 1 first.
monitor_named("DP-3").active = 1
world.handlers["workspace.active"](hl.get_workspace(1))
monitor_named("DP-3").active = nil
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3" })
fire_timers()

plug("DP-3", 3, "LG", free_id())
world.handlers["monitor.added"]({ name = "DP-3" })
check(shows("DP-3") == 4, "DP-3 came back on " .. tostring(shows("DP-3")) .. " instead of workspace 4")
check(world.windows["0xb"].workspace == 4 and on(4) == "DP-3",
  "the window is on " .. world.windows["0xb"].workspace .. " at " .. tostring(on(world.windows["0xb"].workspace)))
check(shows("HDMI-A-1") == 11, "HDMI-A-1 was moved to " .. tostring(shows("HDMI-A-1")))
' || fail "a workspace switch that races the unplug is the one the monitor comes back on"
pass "a workspace switch that races the unplug is the one the monitor comes back on"

# DP-3 (showing 4) unplugs and 4 merges onto HDMI-A-1 as guest 16. Clicking 16
# on the bar fires workspace.active on HDMI-A-1, but must not overwrite
# HDMI-A-1'"'"'s remembered view (15) when HDMI-A-1 later unplugs too.
run_lua guest-click-preserves-host-view '
plug("DP-3", 0, "Samsung", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(4))
window("0xa", 4)
world.focused = "HDMI-A-1"
window("0xb", 11)
hl.dispatch(m.focus(5))
window("0xc", 15)
world.handlers["config.reloaded"]()
check(shows("DP-3") == 4 and shows("HDMI-A-1") == 15,
  "setup left the monitors on " .. tostring(shows("DP-3")) .. " and " .. tostring(shows("HDMI-A-1")))

unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = 4 } })
fire_timers()
local guest = world.windows["0xa"].workspace
check(guest == 16 and on(guest) == "HDMI-A-1",
  "expected DP-3 workspace merged as 16 on HDMI-A-1, got " .. tostring(guest) .. " on " .. tostring(on(guest)))

-- User clicks the merged guest workspace 16 on the bar.
hl.dispatch(hl.dsp.focus({ workspace = tostring(guest) }))
world.handlers["workspace.active"](hl.get_workspace(guest))
fire_timers()

-- Now HDMI-A-1 unplugs too, and both reconnect in order.
unplug("HDMI-A-1")
world.handlers["monitor.removed"]({ name = "HDMI-A-1" })
fire_timers()

plug("DP-3", 0, "Samsung", free_id())
world.handlers["monitor.added"]({ name = "DP-3" })
plug("HDMI-A-1", 1, "Dell", free_id())
world.handlers["monitor.added"]({ name = "HDMI-A-1" })
check(shows("DP-3") == 4, "DP-3 came back on " .. tostring(shows("DP-3")) .. " instead of workspace 4")
check(shows("HDMI-A-1") == 15, "HDMI-A-1 came back on " .. tostring(shows("HDMI-A-1")) .. " instead of workspace 15")
' || fail "clicking a merged guest workspace on the bar does not overwrite the host monitor view"
pass "clicking a merged guest workspace on the bar does not overwrite the host monitor view"

# Stepping workspaces with Super+Tab (o.workspaces.step("m+1")) must also record
# the new view immediately so an unplug before workspace.active'"'"'s 1ms timer does
# not revert to the previous workspace.
run_lua step-races-removal '
plug("DP-3", 0, "LG", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xa", 1)
window("0xb", 4)
world.handlers["config.reloaded"]()
check(shows("DP-3") == 1, "DP-3 was showing " .. tostring(shows("DP-3")))

hl.dispatch(m.step("m+1"))
check(shows("DP-3") == 4, "m.step(m+1) left DP-3 on " .. tostring(shows("DP-3")))
world.handlers["workspace.active"](hl.get_workspace(4))
-- Unplug races before the 1ms timer, with Hyprland activating 1 and clearing active.
monitor_named("DP-3").active = 1
world.handlers["workspace.active"](hl.get_workspace(1))
monitor_named("DP-3").active = nil
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3" })
fire_timers()

plug("DP-3", 3, "LG", free_id())
world.handlers["monitor.added"]({ name = "DP-3" })
check(shows("DP-3") == 4, "DP-3 came back on " .. tostring(shows("DP-3")) .. " instead of workspace 4")
' || fail "Super+Tab workspace step racing unplug still restores the new workspace"
pass "Super+Tab workspace step racing unplug still restores the new workspace"

# DP-3 (showing 4) unplugs and 4 merges onto HDMI-A-1 as guest 16. User clicks 16
# on HDMI-A-1'"'"'s bar via o.workspaces.focus(6, "HDMI-A-1"), then DP-3 reconnects
# FIRST (both when restore() evacuates 16 and when Hyprland pre-evacuates 16 and
# leaves HDMI-A-1 on gap-filler 11). HDMI-A-1 must return to 15 and stay 15 across
# a subsequent unplug/reconnect.
run_lua guest-return-restores-host-view '
for _, pre_evacuate in ipairs({ false, true }) do
  world.monitors, world.workspaces, world.windows, world.timers = {}, {}, {}, {}
  os.execute("rm -rf " .. o.shell_quote(os.getenv("XDG_STATE_HOME") .. "/omarchy/monitors"))
  plug("DP-3", 0, "Samsung", 1)
  plug("HDMI-A-1", 1, "Dell", 11)
  world.focused = "DP-3"
  local m = load_module()
  world.handlers["hyprland.start"]()
  hl.dispatch(m.focus(4))
  window("0xa", 4)
  world.focused = "HDMI-A-1"
  window("0xb", 11)
  hl.dispatch(m.focus(5))
  window("0xc", 15)
  world.handlers["config.reloaded"]()

  unplug("DP-3")
  world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = 4 } })
  fire_timers()
  local guest = world.windows["0xa"].workspace
  check(guest == 16 and on(guest) == "HDMI-A-1", "expected guest 16 on HDMI-A-1, got " .. tostring(guest))

  -- Bar clicks slot 6 on HDMI-A-1 (Workspaces.qml calls o.workspaces.focus for own-block id 16).
  hl.dispatch(m.focus(6, "HDMI-A-1"))
  world.handlers["workspace.active"](hl.get_workspace(guest))
  fire_timers()
  check(shows("HDMI-A-1") == 16, "HDMI-A-1 did not show guest 16")

  -- Plugging in an unrelated third monitor while DP-3 stays offline must keep
  -- HDMI-A-1 on the guest workspace 16 the user is actively viewing.
  plug("DP-4", 2, "BenQ", free_id())
  world.handlers["monitor.added"]({ name = "DP-4" })
  check(shows("HDMI-A-1") == 16, "unrelated monitor plug moved HDMI-A-1 off guest 16 to " .. tostring(shows("HDMI-A-1")))
  unplug("DP-4")
  world.handlers["monitor.removed"]({ name = "DP-4" })
  fire_timers()
  check(shows("HDMI-A-1") == 16, "unplugging unrelated monitor moved HDMI-A-1 off guest 16 to " .. tostring(shows("HDMI-A-1")))

  -- DP-3 reconnects FIRST.
  plug("DP-3", 0, "Samsung", free_id())
  if pre_evacuate then
    -- Model Hyprland 0.56.2 Monitor.cpp:323-338 moving 16 back to DP-3 and
    -- plugging HDMI-A-1'"'"'s gap with 11 before monitor.added fires.
    for _, w in ipairs(world.workspaces) do
      if w.id == guest then w.monitor = "DP-3" end
    end
    monitor_named("HDMI-A-1").active = 11
  end
  world.handlers["monitor.added"]({ name = "DP-3" })
  check(shows("DP-3") == 4, "DP-3 came back on " .. tostring(shows("DP-3")) .. " instead of 4")
  check(shows("HDMI-A-1") == 15, "HDMI-A-1 landed on " .. tostring(shows("HDMI-A-1")) .. " instead of 15 (pre_evacuate=" .. tostring(pre_evacuate) .. ")")

  -- Subsequent unplug/reconnect of HDMI-A-1 must still restore 15.
  unplug("HDMI-A-1")
  world.handlers["monitor.removed"]({ name = "HDMI-A-1" })
  fire_timers()
  plug("HDMI-A-1", 1, "Dell", free_id())
  world.handlers["monitor.added"]({ name = "HDMI-A-1" })
  check(shows("HDMI-A-1") == 15, "HDMI-A-1 came back on " .. tostring(shows("HDMI-A-1")) .. " instead of 15 after replug")
end
' || fail "returning a guest workspace to its monitor restores the host monitor's previous view"
pass "returning a guest workspace to its monitor restores the host monitor's previous view"

# HDMI-A-1 shows 5. DP-4 and DP-3 unplug in order, merging their workspaces into
# HDMI-A-1 as guests 6 and 7. User switches HDMI-A-1 to 7, then only DP-3 returns.
# Even when Hyprland fills the gap with the other offline guest 6, HDMI-A-1 must
# restore its remembered view 5 rather than staying on gap-filler guest 6.
run_lua guest-return-replaces-fallback-guest '
for _, pre_evacuate in ipairs({ false, true }) do
  world.monitors, world.workspaces, world.windows, world.timers = {}, {}, {}, {}
  os.execute("rm -rf " .. o.shell_quote(os.getenv("XDG_STATE_HOME") .. "/omarchy/monitors"))
  plug("HDMI-A-1", 0, "Dell", 1)
  plug("DP-4", 1, "BenQ", 11)
  plug("DP-3", 2, "Samsung", 21)
  world.focused = "HDMI-A-1"
  local m = load_module()
  world.handlers["hyprland.start"]()
  hl.dispatch(m.focus(5))
  window("0xh", 5)
  world.focused = "DP-4"
  window("0x4", 11)
  world.focused = "DP-3"
  window("0x3", 21)
  world.focused = "HDMI-A-1"
  world.handlers["config.reloaded"]()
  check(shows("HDMI-A-1") == 5, "HDMI-A-1 started on " .. tostring(shows("HDMI-A-1")))

  unplug("DP-4")
  world.handlers["monitor.removed"]({ name = "DP-4", active_workspace = { id = 11 } })
  fire_timers()
  local guest4 = world.windows["0x4"].workspace

  unplug("DP-3")
  world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = 21 } })
  fire_timers()
  local guest3 = world.windows["0x3"].workspace
  check(guest4 == 6 and guest3 == 7,
    "expected merged guests 6 and 7, got " .. tostring(guest4) .. " and " .. tostring(guest3))

  -- Switch HDMI-A-1 from 5 to DP-3'"'"'s guest 7.
  hl.dispatch(m.focus(7, "HDMI-A-1"))
  world.handlers["workspace.active"](hl.get_workspace(guest3))
  fire_timers()
  check(shows("HDMI-A-1") == 7, "HDMI-A-1 did not switch to guest 7")

  -- Reconnect only DP-3; Hyprland fills HDMI-A-1'"'"'s gap with guest 6 (placed
  -- ahead of 5 in world.workspaces so move_workspace picks 6 first too).
  for i, w in ipairs(world.workspaces) do
    if w.id == guest4 then
      table.remove(world.workspaces, i)
      table.insert(world.workspaces, 1, w)
      break
    end
  end
  plug("DP-3", 2, "Samsung", free_id())
  if pre_evacuate then
    -- Match Hyprland v0.56.2 WorkspacePlacementController.cpp:288-296: emit
    -- workspace.active(fallback) BEFORE updating the evacuated workspace monitor.
    monitor_named("HDMI-A-1").active = guest4
    world.handlers["workspace.active"](hl.get_workspace(guest4))
    for _, w in ipairs(world.workspaces) do
      if w.id == guest3 then w.monitor = "DP-3" end
    end
  end
  world.handlers["monitor.added"]({ name = "DP-3" })
  fire_timers()
  check(shows("DP-3") == 21, "DP-3 came back on " .. tostring(shows("DP-3")) .. " instead of 21")
  check(shows("HDMI-A-1") == 5,
    "HDMI-A-1 stayed on " .. tostring(shows("HDMI-A-1")) .. " instead of restoring 5 (pre_evacuate=" .. tostring(pre_evacuate) .. ")")
end
' || fail "returning one guest restores the host monitor view even if Hyprland plugs the gap with another guest"
pass "returning one guest restores the host monitor view even if Hyprland plugs the gap with another guest"

# DP-3 (focused) shows 4. HDMI-A-1 shows 15 and also has a window on 11.
# Hyprland 0.56.2, on the first unplug, puts DP-3'"'"'s active workspace on HDMI-A-1
# and shows it there. That guest must not replace the workspace HDMI-A-1 was showing,
# or the second unplug saves the guest and HDMI-A-1 comes back on 11.
run_lua cascade-kvm '
plug("DP-3", 0, "Samsung", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(4))
window("0xa", 4)
world.focused = "HDMI-A-1"
window("0xb", 11)
hl.dispatch(m.focus(5))
window("0xc", 15)
world.handlers["config.reloaded"]()
check(shows("DP-3") == 4 and shows("HDMI-A-1") == 15,
  "setup left the monitors on " .. tostring(shows("DP-3")) .. " and " .. tostring(shows("HDMI-A-1")))

unplug("DP-3")
monitor_named("HDMI-A-1").active = world.windows["0xa"].workspace
world.focused = "HDMI-A-1"
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = 4 } })
fire_timers()

local guest = shows("HDMI-A-1")
unplug("HDMI-A-1")
world.handlers["monitor.removed"]({ name = "HDMI-A-1", active_workspace = { id = guest } })
fire_timers()

plug("DP-3", 0, "Samsung", free_id())
world.handlers["monitor.added"]({ name = "DP-3" })
plug("HDMI-A-1", 1, "Dell", free_id())
world.handlers["monitor.added"]({ name = "HDMI-A-1" })
check(shows("DP-3") == 4, "DP-3 came back on " .. tostring(shows("DP-3")) .. " instead of workspace 4")
check(world.windows["0xa"].workspace == 4 and on(4) == "DP-3",
  "DP-3'"'"'s window is on " .. world.windows["0xa"].workspace .. " at " .. tostring(on(world.windows["0xa"].workspace)))
check(shows("HDMI-A-1") == 15, "HDMI-A-1 came back on " .. tostring(shows("HDMI-A-1")) .. " instead of workspace 15")
check(world.windows["0xc"].workspace == 15 and on(15) == "HDMI-A-1",
  "HDMI-A-1'"'"'s window is on " .. world.windows["0xc"].workspace .. " at " .. tostring(on(world.windows["0xc"].workspace)))
check(shows("DP-3") == 4, "bringing HDMI-A-1 back moved DP-3 to " .. tostring(shows("DP-3")))
' || fail "a cascading unplug keeps each monitor on the workspace it was showing"
pass "a cascading unplug keeps each monitor on the workspace it was showing"

# DP-3 showed workspace 1, and also had a window on 4. While it is away the
# window on 1 is closed, so that workspace is gone. Hyprland then starts the
# returning monitor on a new empty workspace 1. The number is not the old one.
run_lua reused-starter '
plug("DP-3", 0, "LG", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xa", 1)
hl.dispatch(m.focus(4))
window("0xb", 4)
hl.dispatch(hl.dsp.focus({ workspace = "1" }))
world.handlers["config.reloaded"]()
check(shows("DP-3") == 1, "DP-3 was showing " .. tostring(shows("DP-3")))

unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = 1 } })
fire_timers()

world.windows["0xa"] = nil
hl.dispatch(hl.dsp.focus({ workspace = "11" }))
check(on(1) == nil, "the emptied workspace was kept")

plug("DP-3", 3, "LG", 1)
check(shows("DP-3") == 1 and (hl.get_workspace(1).windows or 0) == 0,
  "Hyprland started DP-3 on " .. tostring(shows("DP-3")) .. " with " .. tostring(hl.get_workspace(1) and hl.get_workspace(1).windows) .. " windows")
world.handlers["monitor.added"]({ name = "DP-3" })
check(shows("DP-3") == 4, "DP-3 stayed on empty workspace " .. tostring(shows("DP-3")) .. " while a window waited on 4")
check(world.windows["0xb"].workspace == 4 and on(4) == "DP-3",
  "the window is on " .. world.windows["0xb"].workspace .. " at " .. tostring(on(world.windows["0xb"].workspace)))
check(shows("HDMI-A-1") == 11, "HDMI-A-1 was moved to " .. tostring(shows("HDMI-A-1")))
' || fail "a returning monitor does not stay on the empty workspace that reused its old number"
pass "a returning monitor does not stay on the empty workspace that reused its old number"

# monitor.removed queues its reconcile. The monitor is plugged back, and that
# reconcile runs, before the removal timer. The late timer must not mark it offline.
run_lua stale-removal '
plug("DP-3", 0, "LG", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xa", 1)

unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = 1 } })
plug("DP-3", 0, "LG", free_id())
world.handlers["monitor.added"]({ name = "DP-3" })
fire_timers()
check(state_file():find("0\tDP-3\tLG\n", 1, true), "a stale removal cleared DP-3: " .. state_file():gsub("\n", "\\n"))
check(shows("DP-3") == 1, "DP-3 came back on " .. tostring(shows("DP-3")) .. " instead of workspace 1")
check(world.windows["0xa"].workspace == 1 and on(1) == "DP-3",
  "the window is on " .. world.windows["0xa"].workspace .. " at " .. tostring(on(world.windows["0xa"].workspace)))
check(state_file():find("1\tHDMI-A-1\tDell\n", 1, true), "HDMI-A-1 was cleared: " .. state_file():gsub("\n", "\\n"))
' || fail "a removal that is already undone does not mark the monitor offline"
pass "a removal that is already undone does not mark the monitor offline"

# Both monitors emit monitor.removed before either reconcile runs. With nothing
# plugged in, the state file still has to drop the online connector and keep
# the last one.
run_lua both-offline '
plug("DP-3", 0, "Samsung", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xa", 1)
window("0xb", 11)
local before = state_file()
check(before:find("0\tDP-3\tSamsung\n", 1, true), "DP-3 was not online: " .. before:gsub("\n", "\\n"))
check(before:find("1\tHDMI-A-1\tDell\n", 1, true), "HDMI-A-1 was not online: " .. before:gsub("\n", "\\n"))

unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = 1 } })
unplug("HDMI-A-1")
world.handlers["monitor.removed"]({ name = "HDMI-A-1", active_workspace = { id = 11 } })
fire_timers()

local after = state_file()
check(after:find("0\t\tSamsung\tDP-3\n", 1, true), "DP-3 stayed online: " .. after:gsub("\n", "\\n"))
check(after:find("1\t\tDell\tHDMI-A-1\n", 1, true), "HDMI-A-1 stayed online: " .. after:gsub("\n", "\\n"))
check(not after:find("FALLBACK", 1, true), "FALLBACK took a block: " .. after:gsub("\n", "\\n"))
' || fail "unplugging every monitor clears the online connector and keeps the last one"
pass "unplugging every monitor clears the online connector and keeps the last one"

# F9: HDMI-A-1 (block 1) has slots 11..20 full, with slot 20 holding DP-4'"'"'s
# merged guest. DP-3 unplugs, so its workspace 6 stays out-of-block on HDMI-A-1
# as a guest and the user switches HDMI-A-1 to 6. Plugging back only DP-4 frees
# slot 20 and merge() renumbers guest 6 -> 20. HDMI-A-1 must keep showing that
# same guest (now 20) instead of switching back to 15.
run_lua guest-renumber-keeps-view '
plug("DP-3", 0, "Samsung", 1)
plug("HDMI-A-1", 1, "Dell", 11)
plug("DP-4", 2, "BenQ", 21)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
window("0x3", 6)
world.focused = "HDMI-A-1"
for id = 11, 19 do
  window("0xh" .. id, id)
end
hl.dispatch(m.focus(5))
world.focused = "DP-4"
window("0x4", 21)
world.focused = "HDMI-A-1"
world.handlers["config.reloaded"]()
check(shows("HDMI-A-1") == 15, "HDMI-A-1 started on " .. tostring(shows("HDMI-A-1")))

-- Unplug DP-4 with its workspace evacuated onto HDMI-A-1 so it takes slot 20.
unplug("DP-4")
for _, w in ipairs(world.workspaces) do
  if w.id == 21 then w.monitor = "HDMI-A-1" end
end
world.handlers["monitor.removed"]({ name = "DP-4", active_workspace = { id = 21 } })
fire_timers()
check(world.windows["0x4"].workspace == 20,
  "DP-4 did not merge into slot 20, got " .. tostring(world.windows["0x4"].workspace))

unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = 6 } })
fire_timers()
check(world.windows["0x3"].workspace == 6 and on(6) == "HDMI-A-1",
  "DP-3 guest 6 did not stay out-of-block on HDMI-A-1: ws=" .. tostring(world.windows["0x3"].workspace) .. " on=" .. tostring(on(6)))

-- User views DP-3'"'"'s out-of-block guest 6 on HDMI-A-1.
monitor_named("HDMI-A-1").active = 6
world.handlers["workspace.active"](hl.get_workspace(6))
fire_timers()
check(shows("HDMI-A-1") == 6, "HDMI-A-1 did not show guest 6")

-- Reconnect only DP-4: 20 returns to DP-4 and merge() renumbers guest 6 -> 20.
plug("DP-4", 2, "BenQ", free_id())
world.handlers["monitor.added"]({ name = "DP-4" })
check(world.windows["0x3"].workspace == 20,
  "guest 6 was not renumbered to 20, got " .. tostring(world.windows["0x3"].workspace))
check(shows("HDMI-A-1") == 20,
  "renumbering viewed guest 6 -> 20 switched HDMI-A-1 to " .. tostring(shows("HDMI-A-1")))
' || fail "renumbering a viewed guest workspace on an unrelated monitor plug keeps it in view"
pass "renumbering a viewed guest workspace on an unrelated monitor plug keeps it in view"

# F10: Default SUPER + mouse_down / mouse_up bindings in tiling.lua must route
# through o.workspaces.step so a rapid disconnect before workspace.active'"'"'s
# timer still restores the newly scrolled workspace.
run_lua tiling-scroll-races-removal '
plug("DP-3", 0, "LG", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
local binds = {}
o.workspaces = m
o.bind = function(keys, _, act) binds[keys] = act end
local noop = function() return function() end end
local stub_mt = { __index = function() return noop end }
setmetatable(hl.dsp, stub_mt)
setmetatable(hl.dsp.window, stub_mt)
setmetatable(hl.dsp.workspace, stub_mt)
hl.dsp.group = setmetatable({}, stub_mt)
dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bindings/tiling.lua")
check(type(binds["SUPER + mouse_down"]) == "function" and type(binds["SUPER + mouse_up"]) == "function",
  "SUPER + mouse_down/mouse_up must use o.workspaces.step functions")

world.handlers["hyprland.start"]()
window("0xa", 1)
window("0xb", 4)
world.handlers["config.reloaded"]()
check(shows("DP-3") == 1, "DP-3 started on " .. tostring(shows("DP-3")))

hl.dispatch(binds["SUPER + mouse_down"])
check(shows("DP-3") == 4, "SUPER + mouse_down left DP-3 on " .. tostring(shows("DP-3")))
world.handlers["workspace.active"](hl.get_workspace(4))
-- Disconnect before the 1ms workspace.active timer runs.
monitor_named("DP-3").active = 1
world.handlers["workspace.active"](hl.get_workspace(1))
monitor_named("DP-3").active = nil
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3" })
fire_timers()

plug("DP-3", 0, "LG", free_id())
world.handlers["monitor.added"]({ name = "DP-3" })
check(shows("DP-3") == 4, "DP-3 came back on " .. tostring(shows("DP-3")) .. " instead of 4 after scroll + fast unplug")
' || fail "SUPER + mouse_down scrolling workspace survives rapid unplug before timer"
pass "SUPER + mouse_down scrolling workspace survives rapid unplug before timer"

# F11: When a monitor'"'"'s remembered workspace disappears while away, fallback in
# home() must pick its own occupied workspace (8) ahead of a lower-numbered
# merged guest (6) belonging to another offline monitor.
run_lua fallback-skips-merged-guest '
plug("HDMI-A-1", 0, "Dell", 1)
plug("DP-4", 1, "BenQ", 11)
world.focused = "HDMI-A-1"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(5))
window("0x5", 5)
world.focused = "DP-4"
window("0x4", 11)
world.focused = "HDMI-A-1"
world.handlers["config.reloaded"]()
check(shows("HDMI-A-1") == 5, "HDMI-A-1 started on " .. tostring(shows("HDMI-A-1")))

-- Unplug DP-4 so its workspace merges into HDMI-A-1 as guest 6.
unplug("DP-4")
world.handlers["monitor.removed"]({ name = "DP-4", active_workspace = { id = 11 } })
fire_timers()
check(world.windows["0x4"].workspace == 6,
  "DP-4 did not merge into guest 6, got " .. tostring(world.windows["0x4"].workspace))

-- HDMI-A-1 now has its own occupied workspace 8 alongside DP-4'"'"'s guest 6.
window("0x8", 8)
check(shows("HDMI-A-1") == 5, "HDMI-A-1 moved off 5 to " .. tostring(shows("HDMI-A-1")))

-- Unplug HDMI-A-1 (all monitors offline), close the last window on 5, reconnect only HDMI-A-1.
unplug("HDMI-A-1")
world.handlers["monitor.removed"]({ name = "HDMI-A-1", active_workspace = { id = 5 } })
fire_timers()
world.windows["0x5"] = nil
for i, w in ipairs(world.workspaces) do
  if w.id == 5 then table.remove(world.workspaces, i); break end
end

plug("HDMI-A-1", 0, "Dell", 1)
world.handlers["monitor.added"]({ name = "HDMI-A-1" })
check(shows("HDMI-A-1") == 8,
  "HDMI-A-1 fell back to " .. tostring(shows("HDMI-A-1")) .. " instead of its own workspace 8")
' || fail "fallback after remembered workspace disappears skips merged guests from other monitors"
pass "fallback after remembered workspace disappears skips merged guests from other monitors"

# F12: Monitor A shows 5; monitor B shows 15 (focused) and also has 11.
# Disconnect B (migrating 15 onto A), then disconnect A before the removal timer.
# Reconnect B first (restoring 15), then reconnect A while Hyprland temporarily
# pulls 15 back onto A by connector memory and drops B to 11. place() returns
# 15 to B and own_views() must restore B to 15 rather than accepting 11.
run_lua later-replug-keeps-earlier-view '
plug("DP-3", 0, "Samsung", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(5))
window("0xa", 5)
world.focused = "HDMI-A-1"
window("0xb1", 11)
hl.dispatch(m.focus(5))
window("0xb5", 15)
world.handlers["config.reloaded"]()
check(shows("DP-3") == 5 and shows("HDMI-A-1") == 15,
  "setup left DP-3=" .. tostring(shows("DP-3")) .. " HDMI-A-1=" .. tostring(shows("HDMI-A-1")))

-- Disconnect B (HDMI-A-1): Hyprland evacuates 15 onto A (DP-3) and shows it there.
unplug("HDMI-A-1")
monitor_named("DP-3").active = 15
world.focused = "DP-3"
world.handlers["monitor.removed"]({ name = "HDMI-A-1", active_workspace = { id = 15 } })
-- Disconnect A before the removal timer runs.
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = 15 } })
fire_timers()

-- Reconnect B first: B restores 15.
plug("HDMI-A-1", 1, "Dell", free_id())
world.handlers["monitor.added"]({ name = "HDMI-A-1" })
check(shows("HDMI-A-1") == 15, "B did not restore 15 first: " .. tostring(shows("HDMI-A-1")))

-- Reconnect A: Hyprland pulls 15 onto A by connector memory, dropping B to 11.
-- Emit workspace.active(11) BEFORE moving 15 off B (matching Hyprland v0.56.2
-- WorkspacePlacementController.cpp:288-296) so the unassigned-monitor guard in
-- workspace.active is directly exercised.
plug("DP-3", 0, "Samsung", free_id())
monitor_named("HDMI-A-1").active = 11
world.handlers["workspace.active"](hl.get_workspace(11))
for _, w in ipairs(world.workspaces) do
  if w.id == 15 then w.monitor = "DP-3" end
end
monitor_named("DP-3").active = 15
world.handlers["monitor.added"]({ name = "DP-3" })
check(shows("DP-3") == 5, "A landed on " .. tostring(shows("DP-3")) .. " instead of 5")
check(shows("HDMI-A-1") == 15, "B lost its restored view 15 and landed on " .. tostring(shows("HDMI-A-1")))
' || fail "reconnecting a second monitor does not drop the first monitor back to a fallback workspace"
pass "reconnecting a second monitor does not drop the first monitor back to a fallback workspace"

# F13: B has slots 11..20 full and shows 15. A unplugs leaving out-of-block
# guest 5 on B. User clicks 5 in the bar (native focus -> workspace.active) and
# A reconnects immediately before the 1ms workspace.active timer runs.
# Hyprland evacuates 5 back to A and drops B to 11 before monitor.added fires.
# B must still restore 15.
run_lua bar-guest-click-fast-replug '
plug("DP-3", 0, "Samsung", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(5))
window("0xa", 5)
world.focused = "HDMI-A-1"
for id = 11, 20 do
  window("0xb" .. id, id)
end
hl.dispatch(m.focus(5))
world.handlers["config.reloaded"]()
check(shows("HDMI-A-1") == 15, "B started on " .. tostring(shows("HDMI-A-1")))

unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = 5 } })
fire_timers()
check(world.windows["0xa"].workspace == 5 and on(5) == "HDMI-A-1",
  "A guest 5 did not stay out-of-block on B")

-- Bar click switches B to out-of-block guest 5; A reconnects BEFORE the 1ms timer runs.
monitor_named("HDMI-A-1").active = 5
world.handlers["workspace.active"](hl.get_workspace(5))
plug("DP-3", 0, "Samsung", free_id())
for _, w in ipairs(world.workspaces) do
  if w.id == 5 then w.monitor = "DP-3" end
end
monitor_named("DP-3").active = 5
monitor_named("HDMI-A-1").active = 11
world.handlers["monitor.added"]({ name = "DP-3" })
fire_timers()
check(shows("DP-3") == 5, "A came back on " .. tostring(shows("DP-3")) .. " instead of 5")
check(shows("HDMI-A-1") == 15, "B landed on " .. tostring(shows("HDMI-A-1")) .. " instead of restoring 15")
' || fail "clicking an out-of-block guest in the bar immediately before its monitor returns still restores the host view"
pass "clicking an out-of-block guest in the bar immediately before its monitor returns still restores the host view"

# F15: Four-finger swipe moves the active window to r-1 and follows it via
# o.workspaces.step_window("r-1"). A rapid disconnect/reconnect before the 1ms
# workspace.active timer runs must keep the new workspace (4) rather than
# reverting to the previous occupied workspace (5).
run_lua four-finger-swipe-fast-replug '
plug("DP-3", 0, "LG", 1)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(5))
window("0xa", 5)
window("0xb", 5)
world.handlers["config.reloaded"]()
check(shows("DP-3") == 5, "DP-3 started on " .. tostring(shows("DP-3")))

local gestures = {}
o.workspaces = m
hl.gesture = function(spec) gestures[#gestures + 1] = spec end
dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/gestures.lua")

local swipe_left = nil
for _, g in ipairs(gestures) do
  if g.fingers == 4 and g.direction == "left" then swipe_left = g.action end
end
check(type(swipe_left) == "function", "missing 4-finger left gesture action")
check(o.bind_expressions[swipe_left] == "o.workspaces.step_window(\"r-1\")",
  "unexpected 4-finger left expression: " .. tostring(o.bind_expressions[swipe_left]))

-- 4-finger left moves active window 0xb to workspace 4 and follows it.
world.active_window = "0xb"
hl.dispatch(swipe_left)
world.handlers["workspace.active"](hl.get_workspace(4))
check(shows("DP-3") == 4, "DP-3 did not move to 4 after 4-finger swipe, got " .. tostring(shows("DP-3")))

-- Disconnect and reconnect before the 1ms timer runs; Hyprland v0.56.2 clears
-- active_workspace before emitting monitor.removed and starts the reconnected
-- output on free_id().
monitor_named("DP-3").active = nil
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3" })
plug("DP-3", 0, "LG", free_id())
world.handlers["monitor.added"]({ name = "DP-3" })
fire_timers()
check(shows("DP-3") == 4, "DP-3 reverted to " .. tostring(shows("DP-3")) .. " instead of keeping 4")
' || fail "four-finger window swipe keeps the new workspace across rapid disconnect/reconnect"
pass "four-finger window swipe keeps the new workspace across rapid disconnect/reconnect"

# F16: Host shows 5, clicks guest 11 in the bar (timer runs), then clicks guest
# 21 in the bar and before the 1ms workspace.active timer runs, 11'"'"'s monitor
# reconnects and reclaims inactive 11. Host must stay on 21 rather than being
# pulled back to 5 by a stale showing_guest=11.
run_lua fast-guest-switch-before-old-owner-returns '
plug("HDMI-A-1", 0, "Dell", 1)
plug("DP-4", 1, "BenQ", 11)
plug("DP-3", 2, "Samsung", 21)
world.focused = "HDMI-A-1"
local m = load_module()
world.handlers["hyprland.start"]()
for id = 1, 10 do
  window("0xh" .. id, id)
end
hl.dispatch(m.focus(5))
world.focused = "DP-4"
window("0x4", 11)
world.focused = "DP-3"
window("0x3", 21)
world.focused = "HDMI-A-1"
world.handlers["config.reloaded"]()
check(shows("HDMI-A-1") == 5, "HDMI-A-1 started on " .. tostring(shows("HDMI-A-1")))

unplug("DP-4")
world.handlers["monitor.removed"]({ name = "DP-4", active_workspace = { id = 11 } })
fire_timers()
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = 21 } })
fire_timers()
check(on(11) == "HDMI-A-1" and on(21) == "HDMI-A-1",
  "expected out-of-block guests 11 and 21 on HDMI-A-1")

-- Click guest 11 in the bar and let the 1ms timer settle.
monitor_named("HDMI-A-1").active = 11
world.handlers["workspace.active"](hl.get_workspace(11))
fire_timers()
check(shows("HDMI-A-1") == 11, "HDMI-A-1 did not switch to guest 11")

-- Click guest 21 in the bar, then reconnect DP-4 (owner of now-inactive 11)
-- BEFORE the 1ms timer runs.
monitor_named("HDMI-A-1").active = 21
world.handlers["workspace.active"](hl.get_workspace(21))
plug("DP-4", 1, "BenQ", free_id())
for _, w in ipairs(world.workspaces) do
  if w.id == 11 then w.monitor = "DP-4" end
end
monitor_named("DP-4").active = 11
world.handlers["monitor.added"]({ name = "DP-4" })
fire_timers()
check(shows("DP-4") == 11, "DP-4 came back on " .. tostring(shows("DP-4")) .. " instead of 11")
check(shows("HDMI-A-1") == 21,
  "HDMI-A-1 was pulled from 21 to " .. tostring(shows("HDMI-A-1")) .. " when inactive guest 11 returned")
' || fail "switching guests in the bar before the previous guest monitor returns keeps the new guest"
pass "switching guests in the bar before the previous guest monitor returns keeps the new guest"

# F18/F25/F26: Native workspace switch via hl.dsp.focus racing disconnect before
# the 1ms workspace.active timer runs must not revert when Hyprland v0.56.2
# restores workspace 4 on the same connector: fast replug before merge,
# single-monitor FALLBACK after removal reconcile, full-host-block (id 4 kept)
# after removal reconcile, free-host-block (1->12, 4->13 merged), host switching
# away from guest 13 back to 11 while offline, and config reload while offline.
run_lua native-switch-races-removal '
for _, mode in ipairs({
  "fast-replug",
  "single-after-remove",
  "single-reload-offline",
  "full-host-after-remove",
  "free-host-after-remove",
  "free-host-switch-away",
  "free-host-reload-offline",
  "free-host-unfocused-migrate",
  "free-host-unfocused-old-first",
  "single-reload-disables",
}) do
  world.monitors, world.workspaces, world.windows, world.timers = {}, {}, {}, {}
  os.execute("rm -rf " .. o.shell_quote(os.getenv("XDG_STATE_HOME") .. "/omarchy/monitors"))
  plug("DP-3", 0, "LG", 1)
  local sole = mode == "single-after-remove"
    or mode == "single-reload-offline"
    or mode == "single-reload-disables"
  if not sole then
    plug("HDMI-A-1", 1, "Dell", 11)
  end
  world.focused = "DP-3"
  local m = load_module()
  world.handlers["hyprland.start"]()
  window("0xa", 1)
  window("0xb", 4)
  local free_host = mode == "free-host-after-remove"
    or mode == "free-host-switch-away"
    or mode == "free-host-reload-offline"
    or mode == "free-host-unfocused-migrate"
    or mode == "free-host-unfocused-old-first"
  if mode == "full-host-after-remove" then
    world.focused = "HDMI-A-1"
    for id = 11, 20 do
      window("0xh" .. id, id)
    end
    world.focused = "DP-3"
  elseif free_host then
    world.focused = "HDMI-A-1"
    window("0xh11", 11)
    world.focused = "DP-3"
  end
  world.handlers["config.reloaded"]()
  check(shows("DP-3") == 1, "DP-3 started on " .. tostring(shows("DP-3")))

  -- Native switch (not m.focus): workspace.active fires, 1ms timer has not run yet.
  hl.dispatch(hl.dsp.focus({ workspace = "4" }))
  world.handlers["workspace.active"](hl.get_workspace(4))
  if mode == "single-reload-disables" then
    -- F31: hyprctl reload clears timers and reloads Lua BEFORE applying the
    -- monitor rule that disables DP-3 (ConfigManager.cpp:698-725, 810-817).
    world.timers = {}
    m = load_module()
  end
  if free_host then
    if mode == "free-host-unfocused-migrate" or mode == "free-host-unfocused-old-first" then
      world.focused = "HDMI-A-1"
    end
    if mode == "free-host-unfocused-old-first" then
      -- R18: old workspace 1 migrates first (Monitor.cpp:474-489), then 4
      -- migrates and Hyprland plugs DP-3 with a fresh empty workspace.
      for _, w in ipairs(world.workspaces) do
        if w.id == 1 then w.monitor = "HDMI-A-1" end
      end
      local empty_fb = free_id()
      world.workspaces[#world.workspaces + 1] = { id = empty_fb, monitor = "DP-3" }
      monitor_named("DP-3").active = empty_fb
      world.handlers["workspace.active"](hl.get_workspace(empty_fb))
    else
      monitor_named("DP-3").active = 1
      world.handlers["workspace.active"](hl.get_workspace(1))
    end
  end
  monitor_named("DP-3").active = nil
  unplug("DP-3")
  if mode == "full-host-after-remove"
    or (free_host and mode ~= "free-host-unfocused-migrate" and mode ~= "free-host-unfocused-old-first") then
    -- Model Hyprland focusing and displaying the evacuated active workspace 4
    -- on HDMI-A-1 (full block keeps id 4; free block merges 1->12 and 4->13).
    monitor_named("HDMI-A-1").active = 4
    world.focused = "HDMI-A-1"
  end
  world.handlers["monitor.removed"]({ name = "DP-3" })
  if mode == "single-reload-disables" then
    world.handlers["config.reloaded"]()
  end
  if mode ~= "fast-replug" then
    fire_timers()
  end

  if free_host then
    local guest1, guest4 = world.windows["0xa"].workspace, world.windows["0xb"].workspace
    check(guest1 == 12 and guest4 == 13, "expected 1->12 and 4->13 while disconnected")
    check(hl.get_workspace(4) == nil, "expected original id 4 to be merged away")
    if mode == "free-host-switch-away" then
      -- User switches HDMI-A-1 back to 11 while DP-3 is away, so Hyprland will
      -- not activate guest4 (13) on DP-3 during m_lastMonitor recovery.
      hl.dispatch(m.focus(1))
      fire_timers()
      check(shows("HDMI-A-1") == 11, "HDMI-A-1 did not switch back to 11")
    elseif mode == "free-host-reload-offline" then
      -- Config reloads while DP-3 is offline, wiping in-memory pending state.
      m = load_module()
      world.handlers["config.reloaded"]()
    end
    plug("DP-3", 3, "LG", free_id())
    for _, w in ipairs(world.workspaces) do
      if w.id == guest1 or w.id == guest4 then w.monitor = "DP-3" end
    end
    if mode ~= "free-host-switch-away"
      and mode ~= "free-host-unfocused-migrate"
      and mode ~= "free-host-unfocused-old-first" then
      monitor_named("DP-3").active = guest4
      monitor_named("HDMI-A-1").active = 11
    end
  else
    if mode == "single-reload-offline" then
      -- F29: sole monitor goes offline and config reloads before reconnect.
      m = load_module()
      world.handlers["config.reloaded"]()
    end
    -- Model Hyprland v0.56.2 Monitor.cpp:367-374 literally: look up remembered
    -- workspace ID 4 by its original numeric ID before emitting monitor.added.
    local remembered = hl.get_workspace(4)
    check(remembered ~= nil, "expected workspace 4 to still exist by original id in mode=" .. mode)
    plug("DP-3", 3, "LG", 4)
    if mode == "full-host-after-remove" then
      monitor_named("HDMI-A-1").active = 11
    end
    for _, w in ipairs(world.workspaces) do
      if w.id == 4 then w.monitor = "DP-3" end
    end
  end
  world.handlers["monitor.added"]({ name = "DP-3" })
  fire_timers()
  check(world.windows["0xb"].workspace == 4 and on(4) == "DP-3",
    "workspace 4 did not return to DP-3 (mode=" .. mode .. ")")
  check(shows("DP-3") == 4,
    "DP-3 reverted to " .. tostring(shows("DP-3")) .. " instead of keeping native switch 4 (mode=" .. mode .. ")")
  if not sole then
    check(shows("HDMI-A-1") == 11, "HDMI-A-1 moved to " .. tostring(shows("HDMI-A-1")))
  end
end
' || fail "a native workspace switch racing disconnect keeps Hyprland's restored view on reconnect"
pass "a native workspace switch racing disconnect keeps Hyprland's restored view on reconnect"

# F28: Reloading config to re-enable an unplugged output moves the guest
# workspace back onto it and plugs the host with a fallback before
# config.reloaded runs. Because showing_guest is persisted in workspaces-shown,
# the reloaded module still restores the host monitor's remembered view (15).
run_lua reload-reenables-monitor-restores-host-view '
plug("DP-3", 0, "LG", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xa", 1)
world.focused = "HDMI-A-1"
window("0xb11", 11)
hl.dispatch(m.focus(5))
window("0xb15", 15)
world.handlers["config.reloaded"]()
check(shows("HDMI-A-1") == 15, "HDMI-A-1 started on " .. tostring(shows("HDMI-A-1")))

-- Unplug DP-3 so workspace 1 merges onto HDMI-A-1 as guest 16, then view 16.
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3" })
fire_timers()
check(world.windows["0xa"].workspace == 16 and on(16) == "HDMI-A-1",
  "expected DP-3 workspace 1 merged as guest 16 on HDMI-A-1")
hl.dispatch(m.focus(6))
fire_timers()
check(shows("HDMI-A-1") == 16, "HDMI-A-1 did not switch to guest 16")

-- Exact Hyprland v0.56.2 reload sequence (ConfigManager.cpp + WorkspacePlacementController.cpp
-- + MonitorState.cpp): reload clears timers and reloads Lua first, then applies monitor rules
-- which emit workspace.active(11) on HDMI-A-1 BEFORE moving 16 or registering DP-3 in
-- hl.get_monitors(), then move 16 to DP-3, emit monitor.added(DP-3), and emit config.reloaded.
world.timers = {}
m = load_module()
monitor_named("HDMI-A-1").active = 11
world.handlers["workspace.active"](hl.get_workspace(11))
plug("DP-3", 3, "LG", 16)
for _, w in ipairs(world.workspaces) do
  if w.id == 16 then w.monitor = "DP-3" end
end
world.handlers["monitor.added"]({ name = "DP-3" })
world.handlers["config.reloaded"]()
fire_timers()

check(shows("DP-3") == 1, "DP-3 came back on " .. tostring(shows("DP-3")) .. " instead of 1")
check(shows("HDMI-A-1") == 15,
  "HDMI-A-1 stayed on fallback " .. tostring(shows("HDMI-A-1")) .. " instead of restoring 15 after reload")
' || fail "reloading config to re-enable a monitor restores the host monitor's view after viewing its guest"
pass "reloading config to re-enable a monitor restores the host monitor's view after viewing its guest"

# R18: Reloading config to re-enable a monitor whose guest (7) is viewed on a
# host (remembering 5) must still restore 5 even when Hyprland plugs the host
# with another offline monitor's guest (6) BEFORE moving 7 or emitting monitor.added.
run_lua reload-reenables-guest-plugged-with-other-guest '
plug("HDMI-A-1", 0, "Dell", 1)
plug("DP-3", 1, "LG", 11)
plug("DP-4", 2, "BenQ", 21)
world.focused = "HDMI-A-1"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(5))
window("0xh5", 5)
world.focused = "DP-3"
window("0x3", 11)
world.focused = "DP-4"
window("0x4", 21)
world.focused = "HDMI-A-1"
world.handlers["config.reloaded"]()
check(shows("HDMI-A-1") == 5, "HDMI-A-1 started on " .. tostring(shows("HDMI-A-1")))

unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3" })
fire_timers()
unplug("DP-4")
world.handlers["monitor.removed"]({ name = "DP-4" })
fire_timers()
check(world.windows["0x3"].workspace == 6 and world.windows["0x4"].workspace == 7,
  "expected guests 6 and 7 on HDMI-A-1")

-- View guest 7 on HDMI-A-1.
hl.dispatch(m.focus(7))
fire_timers()
check(shows("HDMI-A-1") == 7, "HDMI-A-1 did not switch to guest 7")

-- hyprctl reload re-enables DP-4: Lua reloads first, then Hyprland activates
-- guest 6 as the gap-plug BEFORE moving 7 or registering DP-4.
world.timers = {}
m = load_module()
monitor_named("HDMI-A-1").active = 6
world.handlers["workspace.active"](hl.get_workspace(6))
plug("DP-4", 3, "BenQ", 7)
for _, w in ipairs(world.workspaces) do
  if w.id == 7 then w.monitor = "DP-4" end
end
world.handlers["monitor.added"]({ name = "DP-4" })
world.handlers["config.reloaded"]()
fire_timers()

check(shows("DP-4") == 21, "DP-4 came back on " .. tostring(shows("DP-4")) .. " instead of 21")
check(shows("HDMI-A-1") == 5,
  "HDMI-A-1 stayed on guest " .. tostring(shows("HDMI-A-1")) .. " instead of restoring 5 after reload")
' || fail "reloading config to re-enable a guest monitor restores host view even when plugged with another guest"
pass "reloading config to re-enable a guest monitor restores host view even when plugged with another guest"

# F27: If a monitor was showing workspace 4, unplugged (merging 4 -> 13), and
# while offline a window rule opened a new app on workspace 4, restoring 13 into
# a free slot in DP-3's block updates shown so DP-3 displays its original
# workspace instead of the unrelated new app on 4.
run_lua restored-adopted-slot-updates-shown '
plug("DP-3", 0, "LG", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xold1", 1)
hl.dispatch(m.focus(4))
window("0xold4", 4)
world.focused = "HDMI-A-1"
window("0xb", 11)
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3" })
fire_timers()
check(world.windows["0xold4"].workspace == 13 and not hl.get_workspace(4),
  "workspace 4 was not merged to 13")

-- While DP-3 is offline, a window rule opens a new app on numeric workspace 4.
window("0xnew4", 4)
world.handlers["workspace.created"](hl.get_workspace(4))
check(on(4) == "HDMI-A-1" and shows("HDMI-A-1") == 11, "unexpected host view")

-- DP-3 reconnects on the same connector: Hyprland returns 12/13 via lastMonitor
-- and then finds the newly created numeric id 4 as its remembered workspace.
plug("DP-3", 3, "LG", free_id())
for _, w in ipairs(world.workspaces) do
  if w.id == 12 or w.id == 13 or w.id == 4 then w.monitor = "DP-3" end
end
monitor_named("DP-3").active = 4
world.handlers["monitor.added"]({ name = "DP-3" })
fire_timers()

local orig_ws = world.windows["0xold4"].workspace
check(orig_ws ~= 4 and on(orig_ws) == "DP-3",
  "original workspace should have been adopted to a free DP-3 slot, got " .. tostring(orig_ws))
check(shows("DP-3") == orig_ws,
  "DP-3 showed " .. tostring(shows("DP-3")) .. " (new app on 4) instead of original workspace " .. tostring(orig_ws))
check(shows("HDMI-A-1") == 11, "HDMI-A-1 moved to " .. tostring(shows("HDMI-A-1")))
' || fail "restoring a monitor's shown workspace into an adopted slot displays the original workspace"
pass "restoring a monitor's shown workspace into an adopted slot displays the original workspace"

# F23: Online monitor B restores 15, then C disconnects merging its workspace
# onto B as guest 16. User switches B to guest 16 (timer settles). When A later
# reconnects and Hyprland temporarily pulls hidden 15 onto A by connector memory,
# returning 15 to B must NOT pull B off the still-present guest 16.
run_lua returned-home-preserves-viewed-guest '
plug("DP-3", 0, "Samsung", 1)
plug("HDMI-A-1", 1, "Dell", 11)
plug("DP-4", 2, "BenQ", 21)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(5))
window("0xa", 5)
world.focused = "HDMI-A-1"
window("0xb1", 11)
hl.dispatch(m.focus(5))
window("0xb5", 15)
world.focused = "DP-4"
window("0xc", 21)
world.focused = "HDMI-A-1"
world.handlers["config.reloaded"]()

-- Cascade unplug B then A (15 moves onto A); B reconnects first and restores 15.
unplug("HDMI-A-1")
monitor_named("DP-3").active = 15
world.focused = "DP-3"
world.handlers["monitor.removed"]({ name = "HDMI-A-1", active_workspace = { id = 15 } })
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = 15 } })
fire_timers()

plug("HDMI-A-1", 1, "Dell", free_id())
world.handlers["monitor.added"]({ name = "HDMI-A-1" })
check(shows("HDMI-A-1") == 15, "B did not restore 15: " .. tostring(shows("HDMI-A-1")))

-- C (DP-4) disconnects and merges onto B as guest 16; user views guest 16 on B.
unplug("DP-4")
world.handlers["monitor.removed"]({ name = "DP-4", active_workspace = { id = 21 } })
fire_timers()
local guest = world.windows["0xc"].workspace
check(guest == 16 and on(guest) == "HDMI-A-1", "expected C merged as guest 16 on B, got " .. tostring(guest))
hl.dispatch(m.focus(6, "HDMI-A-1"))
world.handlers["workspace.active"](hl.get_workspace(guest))
fire_timers()
check(shows("HDMI-A-1") == 16, "B did not show guest 16: " .. tostring(shows("HDMI-A-1")))

-- A (DP-3) reconnects and Hyprland temporarily pulls hidden 15 onto A.
plug("DP-3", 0, "Samsung", free_id())
for _, w in ipairs(world.workspaces) do
  if w.id == 15 then w.monitor = "DP-3" end
end
monitor_named("DP-3").active = 15
world.handlers["monitor.added"]({ name = "DP-3" })
fire_timers()
check(shows("DP-3") == 5, "A landed on " .. tostring(shows("DP-3")) .. " instead of 5")
check(shows("HDMI-A-1") == 16,
  "returning hidden 15 pulled B off viewed guest 16 onto " .. tostring(shows("HDMI-A-1")))
' || fail "returning a hidden workspace does not override a still-present viewed guest on an online monitor"
pass "returning a hidden workspace does not override a still-present viewed guest on an online monitor"

# F21: A disconnects while showing B'"'"'s guest 15. B reconnects first (restoring
# 15), then natively switches from 15 to 11 before the 1ms workspace.active
# timer runs. When A reconnects and Hyprland temporarily pulls the now-hidden 15
# onto A by connector memory, returning 15 to B must NOT pull B back from 11.
run_lua online-native-switch-before-returned-home '
plug("DP-3", 0, "Samsung", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(5))
window("0xa", 5)
world.focused = "HDMI-A-1"
window("0xb1", 11)
hl.dispatch(m.focus(5))
window("0xb5", 15)
world.handlers["config.reloaded"]()
check(shows("DP-3") == 5 and shows("HDMI-A-1") == 15,
  "setup left DP-3=" .. tostring(shows("DP-3")) .. " HDMI-A-1=" .. tostring(shows("HDMI-A-1")))

-- Cascade unplug: B (HDMI-A-1) unplugs migrating 15 onto A (DP-3), then A unplugs.
unplug("HDMI-A-1")
monitor_named("DP-3").active = 15
world.focused = "DP-3"
world.handlers["monitor.removed"]({ name = "HDMI-A-1", active_workspace = { id = 15 } })
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = 15 } })
fire_timers()

-- B reconnects first and restores 15.
plug("HDMI-A-1", 1, "Dell", free_id())
world.handlers["monitor.added"]({ name = "HDMI-A-1" })
check(shows("HDMI-A-1") == 15, "B did not restore 15 first: " .. tostring(shows("HDMI-A-1")))

-- User switches online B natively from 15 to 11; before the 1ms timer runs, A
-- reconnects and Hyprland temporarily pulls hidden 15 onto A by connector memory.
hl.dispatch(hl.dsp.focus({ workspace = "11" }))
world.handlers["workspace.active"](hl.get_workspace(11))
check(shows("HDMI-A-1") == 11, "B did not switch to 11: " .. tostring(shows("HDMI-A-1")))

plug("DP-3", 0, "Samsung", free_id())
for _, w in ipairs(world.workspaces) do
  if w.id == 15 then w.monitor = "DP-3" end
end
monitor_named("DP-3").active = 15
world.handlers["monitor.added"]({ name = "DP-3" })
fire_timers()
check(shows("DP-3") == 5, "A landed on " .. tostring(shows("DP-3")) .. " instead of 5")
check(shows("HDMI-A-1") == 11,
  "returning hidden 15 pulled online B from native switch 11 back to " .. tostring(shows("HDMI-A-1")))
' || fail "returning a hidden workspace does not override a native switch on an online monitor"
pass "returning a hidden workspace does not override a native switch on an online monitor"

# R19 F1: Normal unplug of a monitor showing 4 while it also has occupied
# workspace 2 must not promote Hyprland'"'"'s temporary evacuation fallback (2)
# into pending_evacuated across unfocused, focused, and sole-monitor unplugs.
run_lua unplug-multi-workspace-preserves-shown '
for _, variant in ipairs({ "unfocused", "focused", "sole" }) do
  world.monitors, world.workspaces, world.windows, world.timers = {}, {}, {}, {}
  os.execute("rm -rf " .. o.shell_quote(os.getenv("XDG_STATE_HOME") .. "/omarchy/monitors"))
  plug("DP-3", 0, "LG", 1)
  if variant ~= "sole" then
    plug("HDMI-A-1", 1, "Dell", 11)
  end
  world.focused = "DP-3"
  local m = load_module()
  world.handlers["hyprland.start"]()
  hl.dispatch(m.focus(4))
  window("0xa4", 4)
  hl.dispatch(m.focus(2))
  window("0xa2", 2)
  hl.dispatch(m.focus(4))
  if variant ~= "sole" then
    world.focused = "HDMI-A-1"
    window("0xh11", 11)
    if variant == "focused" then
      world.focused = "DP-3"
    end
  end
  fire_timers()
  check(shows("DP-3") == 4, variant .. ": DP-3 started on " .. tostring(shows("DP-3")))

  -- Hyprland v0.56.2 Monitor::onDisconnect moves 4 first (temporarily
  -- activating 2 on DP-3), then moves 2 (temporarily activating an empty
  -- workspace on DP-3).
  monitor_named("DP-3").active = 2
  world.handlers["workspace.active"](hl.get_workspace(2))
  for _, w in ipairs(world.workspaces) do
    if w.id == 4 then
      w.monitor = variant == "sole" and "FALLBACK" or "HDMI-A-1"
    end
  end
  if variant == "focused" then
    monitor_named("HDMI-A-1").active = 4
    world.focused = "HDMI-A-1"
  end
  local empty_fb = free_id()
  world.workspaces[#world.workspaces + 1] = { id = empty_fb, monitor = "DP-3" }
  monitor_named("DP-3").active = empty_fb
  world.handlers["workspace.active"](hl.get_workspace(empty_fb))
  monitor_named("DP-3").active = nil
  unplug("DP-3")
  if variant == "focused" then
    monitor_named("HDMI-A-1").active = 4
    world.focused = "HDMI-A-1"
  end
  world.handlers["monitor.removed"]({ name = "DP-3" })
  fire_timers()

  if variant == "sole" then
    plug("DP-3", 3, "LG", 4)
    for _, w in ipairs(world.workspaces) do
      if w.id == 4 or w.id == 2 then w.monitor = "DP-3" end
    end
  else
    local g4, g2 = world.windows["0xa4"].workspace, world.windows["0xa2"].workspace
    plug("DP-3", 3, "LG", free_id())
    for _, w in ipairs(world.workspaces) do
      if w.id == g4 or w.id == g2 then w.monitor = "DP-3" end
    end
    if variant == "focused" then
      monitor_named("DP-3").active = g4
      monitor_named("HDMI-A-1").active = 11
    end
  end
  world.handlers["monitor.added"]({ name = "DP-3" })
  fire_timers()
  check(shows("DP-3") == 4,
    variant .. ": DP-3 landed on " .. tostring(shows("DP-3")) .. " instead of 4 after unplug")
  if variant ~= "sole" then
    check(shows("HDMI-A-1") == 11,
      variant .. ": HDMI-A-1 moved to " .. tostring(shows("HDMI-A-1")))
  end
end
' || fail "unplugging a monitor with multiple occupied workspaces does not promote evacuation fallback"
pass "unplugging a monitor with multiple occupied workspaces does not promote evacuation fallback"

# R19 F2: Switching natively from a guest workspace on DP-3 to occupied own
# workspace 4 right before focusing HDMI-A-1 and unplugging DP-3 must preserve
# 4 across migration/renumbering and reconnect (even if Hyprland uses either
# workspace 1 or the guest as the teardown fallback).
run_lua native-switch-from-guest-races-unplug '
for _, fb_kind in ipairs({ "own", "guest" }) do
  world.monitors, world.workspaces, world.windows, world.timers = {}, {}, {}, {}
  os.execute("rm -rf " .. o.shell_quote(os.getenv("XDG_STATE_HOME") .. "/omarchy/monitors"))
  plug("DP-3", 0, "LG", 1)
  plug("HDMI-A-1", 1, "Dell", 11)
  plug("DP-4", 2, "BenQ", 21)
  world.focused = "DP-3"
  local m = load_module()
  world.handlers["hyprland.start"]()
  window("0xa1", 1)
  window("0xa4", 4)
  world.focused = "HDMI-A-1"
  window("0xh11", 11)
  world.focused = "DP-4"
  window("0xb21", 21)
  world.focused = "DP-3"
  world.handlers["config.reloaded"]()
  fire_timers()

  -- Unplug DP-4 so its workspace 21 merges onto DP-3 as guest 2.
  unplug("DP-4")
  world.handlers["monitor.removed"]({ name = "DP-4" })
  fire_timers()
  local guest = world.windows["0xb21"].workspace
  check(on(guest) == "DP-3", fb_kind .. ": expected DP-4 guest on DP-3")

  -- View guest on DP-3 and settle.
  hl.dispatch(hl.dsp.focus({ workspace = tostring(guest) }))
  world.handlers["workspace.active"](hl.get_workspace(guest))
  fire_timers()
  check(shows("DP-3") == guest, fb_kind .. ": DP-3 did not view guest")

  -- Native switch from guest to own occupied workspace 4, then before 1ms
  -- timer runs, focus HDMI-A-1 and unplug DP-3.
  hl.dispatch(hl.dsp.focus({ workspace = "4" }))
  world.handlers["workspace.active"](hl.get_workspace(4))
  world.focused = "HDMI-A-1"
  local fb = fb_kind == "guest" and guest or 1
  monitor_named("DP-3").active = fb
  world.handlers["workspace.active"](hl.get_workspace(fb))
  monitor_named("DP-3").active = nil
  unplug("DP-3")
  world.handlers["monitor.removed"]({ name = "DP-3" })
  fire_timers()

  local g1, g4 = world.windows["0xa1"].workspace, world.windows["0xa4"].workspace
  plug("DP-3", 3, "LG", free_id())
  for _, w in ipairs(world.workspaces) do
    if w.id == g1 or w.id == g4 then w.monitor = "DP-3" end
  end
  world.handlers["monitor.added"]({ name = "DP-3" })
  fire_timers()
  check(shows("DP-3") == 4,
    fb_kind .. ": DP-3 reverted to " .. tostring(shows("DP-3")) .. " instead of 4")
  check(shows("HDMI-A-1") == 11,
    fb_kind .. ": HDMI-A-1 moved to " .. tostring(shows("HDMI-A-1")))
end
' || fail "native switch from guest to own workspace survives immediate unfocused unplug"
pass "native switch from guest to own workspace survives immediate unfocused unplug"

# R3 F1: A shows 5 (focused). B shows 15 and also has a window on 11. Unplug A
# and Hyprland shows 5 on B. On reconnect, Hyprland 0.56.2 activates B'"'"'s
# fallback 11 while 5 still belongs to B and before A is in hl.get_monitors()
# (WorkspacePlacementController gap plug, MonitorState inserts A on
# monitor.added). That happens both before and after the removal timer. B must
# return to 15 and A to 5. A real switch to 11 with no reconnect stays on 11.
run_lua reconnect-gap-plug-before-monitor-listed '
for _, phase in ipairs({
  "user-switch-fast",
  "user-switch-settled",
  "before-timer",
  "after-timer",
}) do
  world.monitors, world.workspaces, world.windows, world.timers = {}, {}, {}, {}
  os.execute("rm -rf " .. o.shell_quote(os.getenv("XDG_STATE_HOME") .. "/omarchy/monitors"))
  plug("DP-3", 0, "Samsung", 1)
  plug("HDMI-A-1", 1, "Dell", 11)
  world.focused = "DP-3"
  local m = load_module()
  world.handlers["hyprland.start"]()
  hl.dispatch(m.focus(5))
  window("0xa", 5)
  world.focused = "HDMI-A-1"
  window("0xb1", 11)
  hl.dispatch(m.focus(5))
  window("0xb5", 15)
  world.focused = "DP-3"
  world.handlers["config.reloaded"]()
  fire_timers()
  check(shows("DP-3") == 5 and shows("HDMI-A-1") == 15,
    phase .. " setup left DP-3=" .. tostring(shows("DP-3")) .. " HDMI-A-1=" .. tostring(shows("HDMI-A-1")))

  for _, w in ipairs(world.workspaces) do
    if w.id == 5 then w.monitor = "HDMI-A-1" end
  end
  monitor_named("HDMI-A-1").active = 5
  world.focused = "HDMI-A-1"
  monitor_named("DP-3").active = nil
  unplug("DP-3")
  world.handlers["monitor.removed"]({ name = "DP-3" })
  if phase ~= "before-timer" and phase ~= "user-switch-fast" then
    fire_timers()
  end

  local visitor = world.windows["0xa"].workspace
  check(on(visitor) == "HDMI-A-1", phase .. ": visitor left HDMI-A-1 before the gap plug")
  local listed = false
  for _, mon in ipairs(hl.get_monitors()) do
    if mon.name == "DP-3" then listed = true end
  end
  check(not listed, phase .. ": DP-3 was already in hl.get_monitors()")

  -- Gap plug, or a deliberate switch to 11. DP-3 is not listed yet and the
  -- visitor monitor pointer has not moved.
  monitor_named("HDMI-A-1").active = 11
  world.focused = "HDMI-A-1"
  world.handlers["workspace.active"](hl.get_workspace(11))
  check(on(visitor) == "HDMI-A-1", phase .. ": visitor moved during workspace.active")

  if phase == "user-switch-fast" or phase == "user-switch-settled" then
    fire_timers()
    check(shows("HDMI-A-1") == 11,
      phase .. ": deliberate switch landed on " .. tostring(shows("HDMI-A-1")) .. " instead of 11")
  else
    plug("DP-3", 0, "Samsung", free_id())
    for _, w in ipairs(world.workspaces) do
      if w.id == visitor then w.monitor = "DP-3" end
    end
    monitor_named("DP-3").active = visitor
    world.focused = "DP-3"
    world.handlers["monitor.added"]({ name = "DP-3" })
    fire_timers()
    check(shows("DP-3") == 5, phase .. ": DP-3 landed on " .. tostring(shows("DP-3")) .. " instead of 5")
    check(shows("HDMI-A-1") == 15,
      phase .. ": HDMI-A-1 stayed on " .. tostring(shows("HDMI-A-1")) .. " instead of 15")
  end
end
' || fail "reconnect gap plug before the monitor is listed restores the online monitor view"
pass "reconnect gap plug before the monitor is listed restores the online monitor view"

# R2 F2: A is already offline. B switches from occupied 15 to occupied 18 and
# disconnects before the 1ms timer. A reconnects first and merges 18 away, so
# Hyprland cannot find 18 by its original id when B returns. B must show 18.
run_lua last-monitor-keeps-pending-switch '
plug("DP-3", 0, "Samsung", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(5))
window("0xa", 5)
world.focused = "HDMI-A-1"
window("0xb1", 11)
hl.dispatch(m.focus(5))
window("0xb5", 15)
hl.dispatch(m.focus(8))
window("0xb8", 18)
hl.dispatch(m.focus(5))
fire_timers()
world.handlers["config.reloaded"]()
check(shows("HDMI-A-1") == 15, "B started on " .. tostring(shows("HDMI-A-1")))

unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3" })
fire_timers()

hl.dispatch(hl.dsp.focus({ workspace = "18" }))
world.handlers["workspace.active"](hl.get_workspace(18))
check(shows("HDMI-A-1") == 18, "B did not switch to 18")

-- Last monitor: Hyprland v0.56.2 remembers the active workspace, then clears
-- it, and does not gap-plug another workspace when nothing remains.
monitor_named("HDMI-A-1").active = nil
unplug("HDMI-A-1")
world.handlers["monitor.removed"]({ name = "HDMI-A-1" })
fire_timers()

plug("DP-3", 0, "Samsung", free_id())
world.handlers["monitor.added"]({ name = "DP-3" })
fire_timers()
check(hl.get_workspace(18) == nil, "workspace 18 was still findable by its original id")
check(world.windows["0xb8"].workspace ~= 18, "workspace 18 was not merged onto A")

plug("HDMI-A-1", 1, "Dell", free_id())
world.handlers["monitor.added"]({ name = "HDMI-A-1" })
fire_timers()
check(on(world.windows["0xb8"].workspace) == "HDMI-A-1", "18 did not return home")
check(shows("HDMI-A-1") == 18,
  "B showed " .. tostring(shows("HDMI-A-1")) .. " instead of the pending switch 18")
' || fail "last monitor disconnect keeps a pending native switch to an occupied workspace"
pass "last monitor disconnect keeps a pending native switch to an occupied workspace"

# R2 F3: Same steps as online-native-switch-before-returned-home, but 11 has
# no window. B'"'"'s deliberate switch to that empty workspace must survive A
# reconnecting and returning hidden 15.
run_lua online-empty-switch-before-returned-home '
plug("DP-3", 0, "Samsung", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(5))
window("0xa", 5)
world.focused = "HDMI-A-1"
hl.dispatch(m.focus(5))
window("0xb5", 15)
world.handlers["config.reloaded"]()
check(shows("DP-3") == 5 and shows("HDMI-A-1") == 15,
  "setup left DP-3=" .. tostring(shows("DP-3")) .. " HDMI-A-1=" .. tostring(shows("HDMI-A-1")))

unplug("HDMI-A-1")
monitor_named("DP-3").active = 15
world.focused = "DP-3"
world.handlers["monitor.removed"]({ name = "HDMI-A-1", active_workspace = { id = 15 } })
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = 15 } })
fire_timers()

plug("HDMI-A-1", 1, "Dell", free_id())
world.handlers["monitor.added"]({ name = "HDMI-A-1" })
check(shows("HDMI-A-1") == 15, "B did not restore 15 first: " .. tostring(shows("HDMI-A-1")))

hl.dispatch(hl.dsp.focus({ workspace = "11" }))
world.handlers["workspace.active"](hl.get_workspace(11))
check(shows("HDMI-A-1") == 11, "B did not switch to empty 11: " .. tostring(shows("HDMI-A-1")))
check(hl.get_workspace(11).windows == 0, "workspace 11 was not empty")

plug("DP-3", 0, "Samsung", free_id())
for _, w in ipairs(world.workspaces) do
  if w.id == 15 then w.monitor = "DP-3" end
end
monitor_named("DP-3").active = 15
world.handlers["monitor.added"]({ name = "DP-3" })
fire_timers()
check(shows("DP-3") == 5, "A landed on " .. tostring(shows("DP-3")) .. " instead of 5")
check(shows("HDMI-A-1") == 11,
  "returning hidden 15 pulled online B from empty 11 back to " .. tostring(shows("HDMI-A-1")))
' || fail "returning a hidden workspace does not override a native switch to an empty workspace"
pass "returning a hidden workspace does not override a native switch to an empty workspace"

# R3 F2: Sole monitor DP-3 shows 5. Workspaces 8 and 4 have windows. Native
# switches 5 -> 8 -> 4, or 5 -> 4 -> 8, land before the 1ms timer, then DP-3
# disconnects. Hyprland restores the last selection. The highest id must not win.
run_lua rapid-native-switches-keep-latest '
for _, order in ipairs({ { 8, 4 }, { 4, 8 } }) do
  world.monitors, world.workspaces, world.windows, world.timers = {}, {}, {}, {}
  os.execute("rm -rf " .. o.shell_quote(os.getenv("XDG_STATE_HOME") .. "/omarchy/monitors"))
  plug("DP-3", 0, "LG", 1)
  world.focused = "DP-3"
  local m = load_module()
  world.handlers["hyprland.start"]()
  hl.dispatch(m.focus(5))
  window("0x5", 5)
  window("0x4", 4)
  window("0x8", 8)
  fire_timers()
  world.handlers["config.reloaded"]()
  check(shows("DP-3") == 5, "DP-3 started on " .. tostring(shows("DP-3")))

  local expected = order[#order]
  for _, id in ipairs(order) do
    hl.dispatch(hl.dsp.focus({ workspace = tostring(id) }))
    world.handlers["workspace.active"](hl.get_workspace(id))
  end
  check(shows("DP-3") == expected, "rapid switch did not land on " .. expected)

  -- Sole monitor: Hyprland clears active_workspace and does not gap-plug.
  monitor_named("DP-3").active = nil
  unplug("DP-3")
  world.handlers["monitor.removed"]({ name = "DP-3" })
  fire_timers()

  plug("DP-3", 0, "LG", expected)
  monitor_named("DP-3").active = expected
  world.handlers["monitor.added"]({ name = "DP-3" })
  fire_timers()
  check(shows("DP-3") == expected,
    "order " .. order[1] .. " then " .. order[2] .. " restored " .. tostring(shows("DP-3")) .. " instead of " .. expected)
end
' || fail "rapid native switches before disconnect restore the latest workspace, not the highest id"
pass "rapid native switches before disconnect restore the latest workspace, not the highest id"

# R3 F3: Persistent empty workspace 7 stays selected across disconnect and
# reconnect. A non-persistent empty placeholder still yields to the occupied
# workspace that was showing.
run_lua persistent-empty-survives-reconnect '
for _, mode in ipairs({ "persistent", "placeholder" }) do
  world.monitors, world.workspaces, world.windows, world.timers = {}, {}, {}, {}
  os.execute("rm -rf " .. o.shell_quote(os.getenv("XDG_STATE_HOME") .. "/omarchy/monitors"))
  plug("DP-3", 0, "LG", 1)
  world.focused = "DP-3"
  local m = load_module()
  world.handlers["hyprland.start"]()
  window("0x2", 2)
  window("0x5", 5)
  hl.dispatch(hl.dsp.focus({ workspace = "5" }))
  world.handlers["workspace.active"](hl.get_workspace(5))
  fire_timers()
  check(shows("DP-3") == 5, mode .. ": DP-3 started on " .. tostring(shows("DP-3")))

  local expected = 5
  if mode == "persistent" then
    hl.dispatch(hl.dsp.focus({ workspace = "7" }))
    for _, w in ipairs(world.workspaces) do
      if w.id == 7 then w.is_persistent = true end
    end
    world.handlers["workspace.active"](hl.get_workspace(7))
    fire_timers()
    check(shows("DP-3") == 7, mode .. ": did not switch to 7")
    check(hl.get_workspace(7).is_persistent == true, mode .. ": workspace 7 was not persistent")
    check(hl.get_workspace(7).windows == 0, mode .. ": workspace 7 was not empty")
    expected = 7
  end

  monitor_named("DP-3").active = nil
  unplug("DP-3")
  world.handlers["monitor.removed"]({ name = "DP-3" })
  fire_timers()

  if mode == "persistent" then
    plug("DP-3", 0, "LG", 7)
    for _, w in ipairs(world.workspaces) do
      if w.id == 7 then w.is_persistent = true end
    end
  else
    local placeholder = free_id()
    check(placeholder ~= 5 and placeholder ~= 2, mode .. ": placeholder reused an occupied id " .. placeholder)
    plug("DP-3", 0, "LG", placeholder)
    for _, w in ipairs(world.workspaces) do
      if w.id == placeholder then w.is_persistent = false end
    end
  end
  world.handlers["monitor.added"]({ name = "DP-3" })
  fire_timers()
  check(shows("DP-3") == expected,
    mode .. ": DP-3 showed " .. tostring(shows("DP-3")) .. " instead of " .. expected)
end
' || fail "a persistent empty workspace survives disconnect and reconnect"
pass "a persistent empty workspace survives disconnect and reconnect"

# Reconcile must not index active_workspace when Hyprland has cleared it.
run_lua reconcile-nil-active-workspace '
plug("DP-3", 0, "LG", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(4))
window("0xa", 4)
world.focused = "HDMI-A-1"
window("0xb", 11)
world.handlers["config.reloaded"]()
fire_timers()
monitor_named("HDMI-A-1").active = nil
m.reconcile()
check(shows("DP-3") == 4, "nil active reconcile moved DP-3 to " .. tostring(shows("DP-3")))
check(shows("HDMI-A-1") ~= nil, "HDMI-A-1 was left without a workspace")
' || fail "reconcile does not crash when a monitor has no active workspace"
pass "reconcile does not crash when a monitor has no active workspace"

# Hyprland 0.56.2 reclaims guest3 by activating guest4 (noFocus) BEFORE plug
# and BEFORE guest3.monitor moves. That happens both before and after the
# removal timer. HDMI-A-1 must return to 5. A deliberate guest3 -> guest4
# switch with no reconnect still sticks.
run_lua guest-gap-plug-before-monitor-listed '
for _, phase in ipairs({ "before-timer", "after-timer", "deliberate" }) do
  world.monitors, world.workspaces, world.windows, world.timers = {}, {}, {}, {}
  os.execute("rm -rf " .. o.shell_quote(os.getenv("XDG_STATE_HOME") .. "/omarchy/monitors"))
  plug("HDMI-A-1", 0, "Dell", 1)
  plug("DP-4", 1, "BenQ", 11)
  plug("DP-3", 2, "Samsung", 21)
  world.focused = "HDMI-A-1"
  local m = load_module()
  world.handlers["hyprland.start"]()
  hl.dispatch(m.focus(5))
  window("0xh", 5)
  world.focused = "DP-4"
  window("0x4", 11)
  world.focused = "DP-3"
  window("0x3", 21)
  world.focused = "HDMI-A-1"
  world.handlers["config.reloaded"]()
  fire_timers()
  check(shows("HDMI-A-1") == 5, phase .. ": HDMI-A-1 started on " .. tostring(shows("HDMI-A-1")))

  unplug("DP-4")
  world.handlers["monitor.removed"]({ name = "DP-4", active_workspace = { id = 11 } })
  fire_timers()
  unplug("DP-3")
  world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = 21 } })
  if phase ~= "before-timer" then
    fire_timers()
  end
  local guest4 = world.windows["0x4"].workspace
  local guest3 = world.windows["0x3"].workspace

  monitor_named("HDMI-A-1").active = guest3
  world.focused = "HDMI-A-1"
  world.handlers["workspace.active"](hl.get_workspace(guest3))
  if phase ~= "before-timer" then
    fire_timers()
  end
  check(shows("HDMI-A-1") == guest3, phase .. ": HDMI-A-1 did not view guest3 " .. tostring(guest3))

  monitor_named("HDMI-A-1").active = guest4
  world.focused = "HDMI-A-1"
  local listed = false
  for _, mon in ipairs(hl.get_monitors()) do
    if mon.name == "DP-3" then listed = true end
  end
  check(not listed, phase .. ": DP-3 was already listed")
  check(on(guest3) == "HDMI-A-1", phase .. ": guest3 left HDMI-A-1 before the gap plug")
  world.handlers["workspace.active"](hl.get_workspace(guest4))
  check(on(guest3) == "HDMI-A-1", phase .. ": guest3 moved during workspace.active")

  if phase == "deliberate" then
    fire_timers()
    check(shows("HDMI-A-1") == guest4,
      phase .. ": deliberate switch landed on " .. tostring(shows("HDMI-A-1")) .. " instead of " .. tostring(guest4))
    m.reconcile()
    check(shows("HDMI-A-1") == guest4,
      phase .. ": reconcile dropped the deliberate switch to " .. tostring(shows("HDMI-A-1")))
  else
    plug("DP-3", 2, "Samsung", free_id())
    for _, w in ipairs(world.workspaces) do
      if w.id == guest3 then w.monitor = "DP-3" end
    end
    monitor_named("DP-3").active = guest3
    world.focused = "DP-3"
    world.handlers["monitor.added"]({ name = "DP-3" })
    fire_timers()
    check(shows("DP-3") == 21, phase .. ": DP-3 came back on " .. tostring(shows("DP-3")) .. " instead of 21")
    check(shows("HDMI-A-1") == 5,
      phase .. ": HDMI-A-1 stayed on " .. tostring(shows("HDMI-A-1")) .. " instead of restoring 5")
  end
end
' || fail "guest-to-guest gap plug before the monitor is listed restores the host view"
pass "guest-to-guest gap plug before the monitor is listed restores the host view"

# A native switch onto a persistent empty workspace, before the 1ms timer,
# survives disconnect and reconnect: sole-monitor latest pending, same-connector
# arrival, and promotion of that pending workspace while another monitor remains.
run_lua persistent-empty-pending-switch '
for _, mode in ipairs({ "sole", "arrived", "evacuated" }) do
  world.monitors, world.workspaces, world.windows, world.timers = {}, {}, {}, {}
  os.execute("rm -rf " .. o.shell_quote(os.getenv("XDG_STATE_HOME") .. "/omarchy/monitors"))
  plug("DP-3", 0, "LG", 1)
  if mode ~= "sole" then
    plug("HDMI-A-1", 1, "Dell", 11)
  end
  world.focused = "DP-3"
  local m = load_module()
  world.handlers["hyprland.start"]()
  if mode == "sole" then
    hl.dispatch(m.focus(5))
    window("0x5", 5)
    fire_timers()
    hl.dispatch(hl.dsp.focus({ workspace = "7" }))
    for _, w in ipairs(world.workspaces) do
      if w.id == 7 then w.is_persistent = true end
    end
    world.handlers["workspace.active"](hl.get_workspace(7))
    check(hl.get_workspace(7).windows == 0, mode .. ": 7 was not empty")
    monitor_named("DP-3").active = nil
    unplug("DP-3")
    world.handlers["monitor.removed"]({ name = "DP-3" })
    fire_timers()
    -- Come back on the previous occupied workspace. The pending persistent
    -- switch has to have been saved, or 5 stays in view.
    plug("DP-3", 0, "LG", 5)
    for _, w in ipairs(world.workspaces) do
      if w.id == 7 then
        w.is_persistent = true
        w.monitor = "DP-3"
      end
    end
    monitor_named("DP-3").active = 5
    world.handlers["monitor.added"]({ name = "DP-3" })
    fire_timers()
    check(shows("DP-3") == 7, mode .. ": restored " .. tostring(shows("DP-3")) .. " instead of persistent 7")
  else
    window("0xa", 1)
    world.focused = "HDMI-A-1"
    window("0xb11", 11)
    hl.dispatch(m.focus(5))
    window("0xb15", 15)
    fire_timers()
    hl.dispatch(hl.dsp.focus({ workspace = "17" }))
    for _, w in ipairs(world.workspaces) do
      if w.id == 17 then w.is_persistent = true end
    end
    world.handlers["workspace.active"](hl.get_workspace(17))
    check(hl.get_workspace(17).windows == 0, mode .. ": 17 was not empty")
    if mode == "evacuated" then
      world.focused = "DP-3"
      monitor_named("HDMI-A-1").active = 11
      world.handlers["workspace.active"](hl.get_workspace(11))
    end
    monitor_named("HDMI-A-1").active = nil
    unplug("HDMI-A-1")
    world.handlers["monitor.removed"]({ name = "HDMI-A-1" })
    fire_timers()
    -- arrived: Hyprland puts the pending persistent workspace back on this
    -- connector. evacuated: promotion already saved it, so even starting on
    -- the previous occupied workspace 15 must leave 17 in view.
    local back = mode == "evacuated" and 15 or 17
    plug("HDMI-A-1", 1, "Dell", back)
    for _, w in ipairs(world.workspaces) do
      if w.id == 17 then
        w.is_persistent = true
        w.monitor = "HDMI-A-1"
      end
    end
    monitor_named("HDMI-A-1").active = back
    world.handlers["monitor.added"]({ name = "HDMI-A-1" })
    fire_timers()
    check(shows("HDMI-A-1") == 17,
      mode .. ": restored " .. tostring(shows("HDMI-A-1")) .. " instead of pending persistent 17")
  end
end
' || fail "a pending switch to a persistent empty workspace survives disconnect and reconnect"
pass "a pending switch to a persistent empty workspace survives disconnect and reconnect"

# A persistent empty workspace returns to its monitor when the dock renames the
# connector, instead of staying on the laptop where it waited with no windows.
run_lua persistent-empty-returns-on-renamed-connector '
plug("eDP-1", 0, "Laptop", 1)
plug("DP-1", 1, "Dell", 11)
world.focused = "eDP-1"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xe", 1)
world.focused = "DP-1"
hl.dispatch(hl.dsp.focus({ workspace = "11" }))
for _, w in ipairs(world.workspaces) do
  if w.id == 11 then w.is_persistent = true end
end
world.handlers["workspace.active"](hl.get_workspace(11))
fire_timers()
check(hl.get_workspace(11).windows == 0 and hl.get_workspace(11).is_persistent == true,
  "workspace 11 was not a persistent empty workspace")

unplug("DP-1")
world.handlers["monitor.removed"]({ name = "DP-1", active_workspace = { id = 11 } })
unplug("eDP-1")
world.handlers["monitor.removed"]({ name = "eDP-1", active_workspace = { id = 1 } })
fire_timers()

plug("eDP-1", 0, "Laptop", free_id())
world.handlers["monitor.added"]({ name = "eDP-1" })
check(on(11) == "eDP-1", "persistent 11 left the laptop early, on " .. tostring(on(11)))

plug("DP-3", 1, "Dell", free_id())
for _, w in ipairs(world.workspaces) do
  if w.id == 11 then w.is_persistent = true end
end
world.handlers["monitor.added"]({ name = "DP-3" })
fire_timers()
check(on(11) == "DP-3", "persistent 11 stayed on " .. tostring(on(11)) .. " instead of DP-3")
' || fail "a persistent empty workspace returns when its connector is renamed"
pass "a persistent empty workspace returns when its connector is renamed"

# The remembered persistent empty workspace wins when the returning monitor is
# started on a guest that was merged into its own block.
run_lua persistent-empty-beats-merged-guest '
plug("HDMI-A-1", 0, "Dell", 1)
plug("DP-3", 1, "LG", 11)
world.focused = "HDMI-A-1"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(5))
window("0xh5", 5)
world.focused = "DP-3"
window("0xd", 12)
hl.dispatch(hl.dsp.focus({ workspace = "17" }))
for _, w in ipairs(world.workspaces) do
  if w.id == 17 then w.is_persistent = true end
end
world.handlers["workspace.active"](hl.get_workspace(17))
fire_timers()
check(shows("DP-3") == 17, "DP-3 did not settle on persistent 17")

unplug("HDMI-A-1")
world.handlers["monitor.removed"]({ name = "HDMI-A-1" })
fire_timers()
local guest = world.windows["0xh5"].workspace
check(guest ~= 17, "merged guest reused persistent id 17")
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3", active_workspace = { id = 17 } })
fire_timers()

plug("DP-3", 1, "LG", guest)
for _, w in ipairs(world.workspaces) do
  if w.id == 17 or w.id == guest then w.monitor = "DP-3" end
  if w.id == 17 then w.is_persistent = true end
end
monitor_named("DP-3").active = guest
world.handlers["monitor.added"]({ name = "DP-3" })
fire_timers()
check(shows("DP-3") == 17,
  "DP-3 stayed on merged guest " .. tostring(shows("DP-3")) .. " instead of persistent 17")
' || fail "a returning monitor shows its persistent empty workspace instead of a merged guest"
pass "a returning monitor shows its persistent empty workspace instead of a merged guest"

# Restoring a merged workspace must not park a persistent empty occupant onto
# a scratch id to steal its number.
run_lua persistent-occupant-is-not-parked '
plug("DP-1", 0, "LG", 10)
plug("DP-2", 1, "Dell", 11)
world.focused = "DP-2"
window("0xa", 11)
world.focused = "DP-1"
local m = load_module()
world.handlers["hyprland.start"]()
unplug("DP-2")
world.handlers["monitor.removed"]({ name = "DP-2" })
fire_timers()
check(world.windows["0xa"].workspace == 1, "11 merged to " .. tostring(world.windows["0xa"].workspace))

plug("DP-2", 1, "Dell", 11)
for _, w in ipairs(world.workspaces) do
  if w.id == 11 then w.is_persistent = true end
end
check(hl.get_workspace(11).windows == 0, "starter 11 was not empty")
world.handlers["monitor.added"]({ name = "DP-2" })
fire_timers()
check(hl.get_workspace(11) and hl.get_workspace(11).is_persistent == true,
  "persistent workspace 11 was renumbered away")
check(world.windows["0xa"].workspace ~= 11, "returning workspace took persistent id 11")
' || fail "restore does not park a persistent empty workspace onto a scratch id"
pass "restore does not park a persistent empty workspace onto a scratch id"

# With every monitor offline the in-memory connector map is cleared, so a gap
# plug before monitor.added is not recorded as the workspace to come back on.
run_lua offline-ignores-gap-plug-before-return '
plug("DP-3", 0, "LG", 1)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
hl.dispatch(m.focus(5))
window("0xa", 5)
world.handlers["config.reloaded"]()
fire_timers()
check(shows("DP-3") == 5, "DP-3 started on " .. tostring(shows("DP-3")))

unplug("DP-3")
m.reconcile()
local placeholder = free_id()
check(placeholder ~= 5, "placeholder reused workspace 5")
plug("DP-3", 0, "LG", placeholder)
world.handlers["workspace.active"](hl.get_workspace(placeholder))
fire_timers()
world.handlers["monitor.added"]({ name = "DP-3" })
fire_timers()
check(shows("DP-3") == 5, "gap plug before return stuck on " .. tostring(shows("DP-3")) .. " instead of 5")
local state = state_file()
check(state:find("0\tDP-3\tLG", 1, true), "DP-3 was not assigned again: " .. state:gsub("\n", "\\n"))
' || fail "a gap plug while every monitor is offline does not replace the shown workspace"
pass "a gap plug while every monitor is offline does not replace the shown workspace"

# Sole/last monitor teardown clears pending_active so gap-filler ids (both in a
# 2-monitor KVM return after renumbering and on a persistent empty slot 1) cannot
# hijack arrived_pending on reconnect.
run_lua sole-teardown-clears-pending-active '
for _, variant in ipairs({ "kvm-renumber", "persistent-slot" }) do
  world.monitors, world.workspaces, world.windows, world.timers = {}, {}, {}, {}
  os.execute("rm -rf " .. o.shell_quote(os.getenv("XDG_STATE_HOME") .. "/omarchy/monitors"))
  plug("DP-3", 0, "Samsung", 1)
  if variant == "kvm-renumber" then
    plug("HDMI-A-1", 1, "Dell", 11)
  end
  world.focused = "DP-3"
  local m = load_module()
  world.handlers["hyprland.start"]()
  if variant == "kvm-renumber" then
    window("0xa2", 2)
    window("0xa4", 4)
    world.focused = "HDMI-A-1"
    window("0xh11", 11)
    world.focused = "DP-3"
  else
    for _, w in ipairs(world.workspaces) do
      if w.id == 1 then w.is_persistent = true end
    end
    window("0xa4", 4)
  end
  hl.dispatch(m.focus(4))
  world.handlers["config.reloaded"]()
  fire_timers()
  check(shows("DP-3") == 4, variant .. ": DP-3 started on " .. tostring(shows("DP-3")))

  if variant == "kvm-renumber" then
    unplug("HDMI-A-1")
    world.handlers["monitor.removed"]({ name = "HDMI-A-1" })
    fire_timers()
  end

  -- DP-3 is now the last monitor (#others == 0). Evacuating 4 activates gap-filler
  -- (2 or persistent 1) while 4 is still on DP-3, then evacuating that activates
  -- an empty fallback before monitor.removed.
  local filler = variant == "kvm-renumber" and 2 or 1
  monitor_named("DP-3").active = filler
  world.handlers["workspace.active"](hl.get_workspace(filler))
  for _, w in ipairs(world.workspaces) do
    if w.id == 4 then w.monitor = "FALLBACK" end
  end
  local empty_fb = free_id()
  world.workspaces[#world.workspaces + 1] = { id = empty_fb, monitor = "DP-3" }
  monitor_named("DP-3").active = empty_fb
  world.handlers["workspace.active"](hl.get_workspace(empty_fb))
  monitor_named("DP-3").active = nil
  unplug("DP-3")
  world.handlers["monitor.removed"]({ name = "DP-3" })
  fire_timers()

  if variant == "kvm-renumber" then
    plug("HDMI-A-1", 1, "Dell", 11)
    for _, w in ipairs(world.workspaces) do
      if w.id == 2 or w.id == 4 or w.id == 11 then w.monitor = "HDMI-A-1" end
    end
    world.handlers["monitor.added"]({ name = "HDMI-A-1" })
    fire_timers()
    local g2, g4 = world.windows["0xa2"].workspace, world.windows["0xa4"].workspace
    check(g2 ~= 2 and g4 ~= 4, "expected 2 and 4 to merge onto HDMI-A-1")
    plug("DP-3", 0, "Samsung", g2)
    for _, w in ipairs(world.workspaces) do
      if w.id == g2 or w.id == g4 then w.monitor = "DP-3" end
    end
    monitor_named("DP-3").active = g2
    world.handlers["monitor.added"]({ name = "DP-3" })
    fire_timers()
  else
    plug("DP-3", 0, "Samsung", 1)
    for _, w in ipairs(world.workspaces) do
      if w.id == 1 or w.id == 4 then w.monitor = "DP-3" end
      if w.id == 1 then w.is_persistent = true end
    end
    monitor_named("DP-3").active = 1
    world.handlers["monitor.added"]({ name = "DP-3" })
    fire_timers()
  end
  check(shows("DP-3") == 4, variant .. ": DP-3 landed on " .. tostring(shows("DP-3")) .. " instead of 4")
end
' || fail "sole monitor teardown clears pending_active gap-fillers"
pass "sole monitor teardown clears pending_active gap-fillers"

# Staggered dock/KVM unplug while viewing a visiting guest must not promote a
# teardown fallback workspace into shown.
run_lua staggered-dock-unplug-while-viewing-guest '
plug("eDP-1", 0, "Laptop", 1)
plug("DP-3", 1, "LG", 11)
plug("HDMI-A-1", 2, "Dell", 21)
world.focused = "eDP-1"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xe1", 1)
world.focused = "DP-3"
window("0xd14", 14)
hl.dispatch(m.focus(4))
world.focused = "HDMI-A-1"
window("0xh21", 21)
window("0xh25", 25)
hl.dispatch(m.focus(5))
world.focused = "DP-3"
world.handlers["config.reloaded"]()
fire_timers()
check(shows("DP-3") == 14, "DP-3 started on " .. tostring(shows("DP-3")))
check(shows("HDMI-A-1") == 25, "HDMI-A-1 started on " .. tostring(shows("HDMI-A-1")))

-- DP-3 drops first; Hyprland moves 14 onto HDMI-A-1 and focuses HDMI-A-1 there.
for _, w in ipairs(world.workspaces) do
  if w.id == 14 then w.monitor = "HDMI-A-1" end
end
monitor_named("HDMI-A-1").active = 14
world.focused = "HDMI-A-1"
monitor_named("DP-3").active = nil
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3" })
fire_timers()
local guest = world.windows["0xd14"].workspace
check(on(guest) == "HDMI-A-1" and shows("HDMI-A-1") == guest,
  "HDMI-A-1 should view merged guest from DP-3, got " .. tostring(shows("HDMI-A-1")))

-- HDMI-A-1 drops next while eDP-1 stays online. Moving active guest to eDP-1
-- first activates 21 on HDMI-A-1 while guest still names HDMI-A-1, then moves
-- guest & focus to eDP-1, then evacuates 21 off unfocused HDMI-A-1.
monitor_named("HDMI-A-1").active = 21
world.handlers["workspace.active"](hl.get_workspace(21))
for _, w in ipairs(world.workspaces) do
  if w.id == guest then w.monitor = "eDP-1" end
end
monitor_named("eDP-1").active = guest
world.focused = "eDP-1"
local empty_fb = free_id()
world.workspaces[#world.workspaces + 1] = { id = empty_fb, monitor = "HDMI-A-1" }
monitor_named("HDMI-A-1").active = empty_fb
world.handlers["workspace.active"](hl.get_workspace(empty_fb))
for _, w in ipairs(world.workspaces) do
  if w.id == 21 or w.id == 25 then w.monitor = "eDP-1" end
end
monitor_named("HDMI-A-1").active = nil
unplug("HDMI-A-1")
world.handlers["monitor.removed"]({ name = "HDMI-A-1" })
fire_timers()

-- Dock returns: HDMI-A-1 must restore 25 (not teardown fallback 21) and DP-3 must restore 14.
plug("HDMI-A-1", 2, "Dell", free_id())
world.handlers["monitor.added"]({ name = "HDMI-A-1" })
fire_timers()
plug("DP-3", 1, "LG", free_id())
world.handlers["monitor.added"]({ name = "DP-3" })
fire_timers()
check(shows("HDMI-A-1") == 25, "HDMI-A-1 landed on " .. tostring(shows("HDMI-A-1")) .. " instead of 25")
check(shows("DP-3") == 14, "DP-3 landed on " .. tostring(shows("DP-3")) .. " instead of 14")
' || fail "staggered dock unplug while viewing a visiting guest preserves remembered view"
pass "staggered dock unplug while viewing a visiting guest preserves remembered view"

# Native workspace switch from an empty non-persistent workspace destroys that
# empty workspace before workspace.active fires; it must not be mistaken for
# shown_evacuated teardown fallback.
run_lua native-switch-from-empty-races-unplug '
plug("DP-3", 0, "LG", 1)
plug("HDMI-A-1", 1, "Dell", 11)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xa2", 2)
window("0xa4", 4)
world.focused = "HDMI-A-1"
window("0xh11", 11)
world.focused = "DP-3"
hl.dispatch(m.focus(7))
world.handlers["config.reloaded"]()
fire_timers()
check(shows("DP-3") == 7, "DP-3 did not settle on empty 7")

-- Switch natively from empty 7 to occupied 4; empty 7 is destroyed before
-- workspace.active(4) fires. Then disconnect before the 1ms timer runs.
hl.dispatch(hl.dsp.focus({ workspace = "4" }))
for i = #world.workspaces, 1, -1 do
  if world.workspaces[i].id == 7 then table.remove(world.workspaces, i) end
end
world.handlers["workspace.active"](hl.get_workspace(4))
for _, w in ipairs(world.workspaces) do
  if w.id == 2 or w.id == 4 then w.monitor = "HDMI-A-1" end
end
monitor_named("HDMI-A-1").active = 4
world.focused = "HDMI-A-1"
monitor_named("DP-3").active = nil
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3" })
fire_timers()

local g2, g4 = world.windows["0xa2"].workspace, world.windows["0xa4"].workspace
plug("DP-3", 0, "LG", g4)
for _, w in ipairs(world.workspaces) do
  if w.id == g2 or w.id == g4 then w.monitor = "DP-3" end
end
monitor_named("DP-3").active = g4
world.handlers["monitor.added"]({ name = "DP-3" })
fire_timers()
check(shows("DP-3") == 4, "DP-3 landed on " .. tostring(shows("DP-3")) .. " instead of 4")
' || fail "native switch from an empty workspace survives immediate unplug"
pass "native switch from an empty workspace survives immediate unplug"

# Persistent empty guests stay in view across config.reloaded, and switching
# natively from a guest onto a persistent empty own workspace is preserved
# across immediate unfocused unplug.
run_lua persistent-empty-guest-and-switch-from-guest '
plug("eDP-1", 0, "Laptop", 1)
plug("DP-1", 1, "LG", 11)
world.focused = "eDP-1"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xe1", 1)
world.focused = "DP-1"
for _, w in ipairs(world.workspaces) do
  if w.id == 11 then w.is_persistent = true end
end
world.focused = "eDP-1"
world.handlers["config.reloaded"]()
fire_timers()

unplug("DP-1")
for _, w in ipairs(world.workspaces) do
  if w.id == 11 then w.monitor = "eDP-1" end
end
world.handlers["monitor.removed"]({ name = "DP-1" })
fire_timers()
local guest = nil
for _, w in ipairs(world.workspaces) do
  if w.is_persistent and w.monitor == "eDP-1" and w.id ~= 1 then guest = w.id end
end
check(guest ~= nil, "persistent empty guest from DP-1 was lost")
hl.dispatch(hl.dsp.focus({ workspace = tostring(guest) }))
world.handlers["workspace.active"](hl.get_workspace(guest))
fire_timers()
check(shows("eDP-1") == guest, "eDP-1 did not show persistent empty guest")
world.handlers["config.reloaded"]()
fire_timers()
check(shows("eDP-1") == guest, "config.reloaded kicked eDP-1 off persistent empty guest to " .. tostring(shows("eDP-1")))

-- Native switch from a guest onto a persistent empty own workspace right before
-- unfocused unplug preserves that persistent empty workspace on reconnect.
world.monitors, world.workspaces, world.windows, world.timers = {}, {}, {}, {}
os.execute("rm -rf " .. o.shell_quote(os.getenv("XDG_STATE_HOME") .. "/omarchy/monitors"))
plug("DP-3", 0, "LG", 1)
plug("HDMI-A-1", 1, "Dell", 11)
plug("DP-4", 2, "BenQ", 21)
world.focused = "DP-3"
m = load_module()
world.handlers["hyprland.start"]()
window("0xa2", 2)
world.workspaces[#world.workspaces + 1] = { id = 7, monitor = "DP-3", is_persistent = true }
world.focused = "HDMI-A-1"
window("0xh11", 11)
world.focused = "DP-4"
window("0xb21", 21)
world.focused = "DP-3"
world.handlers["config.reloaded"]()
fire_timers()

unplug("DP-4")
world.handlers["monitor.removed"]({ name = "DP-4" })
fire_timers()
local g21 = world.windows["0xb21"].workspace
check(on(g21) == "DP-3", "DP-4 guest did not land on DP-3")
hl.dispatch(hl.dsp.focus({ workspace = tostring(g21) }))
world.handlers["workspace.active"](hl.get_workspace(g21))
fire_timers()
check(shows("DP-3") == g21, "DP-3 did not settle on guest")

hl.dispatch(hl.dsp.focus({ workspace = "7" }))
world.handlers["workspace.active"](hl.get_workspace(7))
world.focused = "HDMI-A-1"
monitor_named("DP-3").active = 2
world.handlers["workspace.active"](hl.get_workspace(2))
for _, w in ipairs(world.workspaces) do
  if w.id == 2 or w.id == 7 then w.monitor = "HDMI-A-1" end
end
monitor_named("DP-3").active = nil
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3" })
fire_timers()

local g2 = world.windows["0xa2"].workspace
plug("DP-3", 0, "LG", g2)
for _, w in ipairs(world.workspaces) do
  if w.id == g2 or w.id == 7 or w.is_persistent then w.monitor = "DP-3" end
end
world.handlers["monitor.added"]({ name = "DP-3" })
fire_timers()
check(shows("DP-3") == 7, "DP-3 landed on " .. tostring(shows("DP-3")) .. " instead of persistent 7")
' || fail "persistent empty guest and switch from guest to persistent empty workspace are preserved"
pass "persistent empty guest and switch from guest to persistent empty workspace are preserved"

# Cascading staggered dock unplug records a departed visiting guest on the
# survivor so a fast reconnect of the original monitor restores the survivor view.
run_lua cascaded-guest-notified-on-survivor '
plug("eDP-1", 0, "Laptop", 1)
plug("DP-3", 1, "LG", 11)
plug("HDMI-A-1", 2, "Dell", 21)
world.focused = "eDP-1"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xe1", 1)
window("0xe5", 5)
hl.dispatch(m.focus(5))
world.focused = "DP-3"
window("0xd14", 14)
hl.dispatch(m.focus(4))
world.focused = "HDMI-A-1"
window("0xh25", 25)
hl.dispatch(m.focus(5))
world.focused = "DP-3"
world.handlers["config.reloaded"]()
fire_timers()
check(shows("eDP-1") == 5, "eDP-1 started on " .. tostring(shows("eDP-1")))

-- DP-3 drops first; 14 merges onto HDMI-A-1 as guest and HDMI-A-1 views it.
for _, w in ipairs(world.workspaces) do
  if w.id == 14 then w.monitor = "HDMI-A-1" end
end
monitor_named("HDMI-A-1").active = 14
world.focused = "HDMI-A-1"
monitor_named("DP-3").active = nil
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3" })
fire_timers()
local guest = world.windows["0xd14"].workspace
check(on(guest) == "HDMI-A-1" and shows("HDMI-A-1") == guest, "HDMI-A-1 did not view guest")

-- HDMI-A-1 drops while focused on guest; Hyprland evacuates guest to eDP-1
-- without emitting workspace.active on eDP-1.
for _, w in ipairs(world.workspaces) do
  if w.id == guest or w.id == 25 then w.monitor = "eDP-1" end
end
monitor_named("eDP-1").active = guest
world.focused = "eDP-1"
monitor_named("HDMI-A-1").active = nil
unplug("HDMI-A-1")
world.handlers["monitor.removed"]({ name = "HDMI-A-1" })

-- Before HDMI-A-1 removal timer runs, DP-3 reconnects, reclaims guest, and
-- Hyprland gap-plugs eDP-1 with 1. eDP-1 must restore 5, not save 1.
plug("DP-3", 1, "LG", guest)
for _, w in ipairs(world.workspaces) do
  if w.id == guest then w.monitor = "DP-3" end
end
monitor_named("eDP-1").active = 1
world.handlers["workspace.active"](hl.get_workspace(1))
world.handlers["monitor.added"]({ name = "DP-3" })
fire_timers()
check(shows("eDP-1") == 5, "eDP-1 landed on " .. tostring(shows("eDP-1")) .. " instead of 5")
check(shows("DP-3") == 14, "DP-3 landed on " .. tostring(shows("DP-3")) .. " instead of 14")
' || fail "cascaded visiting guest on staggered unplug restores survivor view on fast reconnect"
pass "cascaded visiting guest on staggered unplug restores survivor view on fast reconnect"

# mark_away clears showing_guest so a stale guest id cannot override
# arrived_pending when a monitor switches natively from a guest to its own
# workspace right before disconnecting without promoting pending_active.
run_lua away-clears-showing-guest-for-arrived-pending '
plug("DP-3", 0, "LG", 1)
plug("HDMI-A-1", 1, "Dell", 11)
plug("DP-4", 2, "BenQ", 21)
world.focused = "DP-3"
local m = load_module()
world.handlers["hyprland.start"]()
window("0xa1", 1)
window("0xa4", 4)
world.focused = "HDMI-A-1"
window("0xh11", 11)
world.focused = "DP-4"
window("0xb21", 21)
world.focused = "DP-3"
world.handlers["config.reloaded"]()
fire_timers()
check(shows("DP-3") == 1, "DP-3 started on " .. tostring(shows("DP-3")))

unplug("DP-4")
world.handlers["monitor.removed"]({ name = "DP-4" })
fire_timers()
local guest = world.windows["0xb21"].workspace
check(on(guest) == "DP-3", "DP-4 guest did not land on DP-3")
hl.dispatch(hl.dsp.focus({ workspace = tostring(guest) }))
world.handlers["workspace.active"](hl.get_workspace(guest))
fire_timers()
check(shows("DP-3") == guest, "DP-3 did not settle on guest")

-- Switch natively from guest to own occupied 4, then unplug DP-3 immediately
-- with no teardown workspace.active and HDMI-A-1 staying on 11 (so 4 stays in
-- pending_active instead of being promoted in mark_away).
hl.dispatch(hl.dsp.focus({ workspace = "4" }))
world.handlers["workspace.active"](hl.get_workspace(4))
for _, w in ipairs(world.workspaces) do
  if w.id == 1 or w.id == 4 or w.id == guest then w.monitor = "HDMI-A-1" end
end
monitor_named("DP-3").active = nil
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3" })
fire_timers()

-- DP-3 returns on the same connector with Hyprland restoring 4 (merged id).
local g1, g4 = world.windows["0xa1"].workspace, world.windows["0xa4"].workspace
plug("DP-3", 0, "LG", g4)
for _, w in ipairs(world.workspaces) do
  if w.id == g1 or w.id == g4 then w.monitor = "DP-3" end
end
monitor_named("DP-3").active = g4
world.handlers["monitor.added"]({ name = "DP-3" })
fire_timers()
check(shows("DP-3") == 4, "DP-3 reverted to " .. tostring(shows("DP-3")) .. " instead of 4")
' || fail "mark_away clears stale showing_guest so arrived_pending restores native switch"
pass "mark_away clears stale showing_guest so arrived_pending restores native switch"
