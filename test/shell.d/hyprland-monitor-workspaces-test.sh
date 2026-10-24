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
world = { monitors = {}, workspaces = {}, windows = {}, neighbours = {}, focused = nil, active_window = nil, swaps = 0, handlers = {} }

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
  dispatch = function(dispatcher) return dispatcher() end,
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

-- A fresh config load, as a reload or the next session gives.
function load_module()
  package.loaded["default.hypr.monitor-workspaces"] = nil
  return require("default.hypr.monitor-workspaces")
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
  local file = io.open(os.getenv("XDG_STATE_HOME") .. "/omarchy/monitor-workspaces")
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

-- After a hotplug the bar can still name the screen that went away, or the
-- FALLBACK that stood in for it (#16351). The click lands on the focused one.
hl.dispatch(m.focus(4, "FALLBACK"))
check(shows("eDP-1") == 4 and world.focused == "eDP-1", "a monitor name Hyprland no longer has falls back to the focused monitor")
hl.dispatch(m.focus(5, ""))
check(shows("eDP-1") == 5, "an empty monitor name falls back to the focused monitor")

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
check(world.windows["0xb"].workspace == 12 and on(12) == "eDP-1", "with all ten taken it waits as a guest")

plug("DP-3", 3, "LG", 13)
world.handlers["monitor.added"]({ name = "DP-3" })
check(on(12) == "DP-3", "and goes home all the same")

-- A new session starts with nothing to bring back.
unplug("DP-3")
world.handlers["monitor.removed"]({ name = "DP-3" })
load_module()
world.handlers["hyprland.start"]()
local file = io.open(os.getenv("XDG_STATE_HOME") .. "/omarchy/monitor-workspaces-merged")
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
