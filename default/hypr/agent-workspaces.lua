-- Where agent seat windows go. Apps agents drive with their own pointer and
-- keyboard open on the seat's workspace, 10 by default, one for the whole
-- desktop.
--
-- Change it in ~/.config/hypr/hyprland.lua:
--
--   require("default.hypr.agent-workspaces").set({ seat = 8 })
--
-- If you give each monitor its own bank of workspaces (1-10 on one, 11-20 on
-- the next), give the seat a workspace on every monitor too, so an agent app
-- opens on the monitor you're working on:
--
--   require("default.hypr.agent-workspaces").set({ per_monitor = 10 })
--
-- Monitors are counted from the left, so the leftmost uses 10, the next 20,
-- and so on. List output names to count them in another order:
--
--   require("default.hypr.agent-workspaces").set({ per_monitor = 10, monitors = { "DP-3", "DP-2" } })

local M = {}

M.settings = {
  seat = 10,
  per_monitor = 0,
  monitors = {},
}

-- Rules are named so rewriting one replaces it rather than stacking another,
-- which is how the workspace follows the monitor you're on.
local placements = {}

local function monitor_index(active)
  if M.settings.per_monitor == 0 or not active then
    return 0
  end

  for index, name in ipairs(M.settings.monitors) do
    if name == active.name then
      return index - 1
    end
  end

  -- Unlisted monitors follow the listed ones, counted from the left.
  local listed = {}
  for _, name in ipairs(M.settings.monitors) do
    listed[name] = true
  end
  -- Counted with # rather than ipairs: the keybindings menu loads this config
  -- with a stand-in hl whose every field is itself, which ipairs would walk
  -- until memory runs out, while # sees it as empty.
  local monitors = hl.get_monitors() or {}
  local rest = {}
  for index = 1, #monitors do
    local monitor = monitors[index]
    if not listed[monitor.name] then
      table.insert(rest, monitor)
    end
  end
  table.sort(rest, function(a, b)
    if a.x ~= b.x then
      return a.x < b.x
    end
    return a.y < b.y
  end)
  for index, monitor in ipairs(rest) do
    if monitor.name == active.name then
      return #M.settings.monitors + index - 1
    end
  end
  return 0
end

-- The seat's workspace on a monitor, the focused one unless given.
function M.workspace(monitor)
  return M.settings.seat + monitor_index(monitor or hl.get_active_monitor()) * M.settings.per_monitor
end

local function apply()
  local workspace = tostring(M.workspace())
  for name, placement in pairs(placements) do
    hl.window_rule({
      name = name,
      match = placement.match,
      workspace = placement.silent and workspace .. " silent" or workspace,
    })
  end
end

-- Sends windows matching `match` to the seat's workspace on the monitor they
-- open on. A silent placement leaves you where you are; otherwise the window
-- takes you there.
function M.place(name, match, silent)
  placements[name] = { match = match, silent = silent }
  apply()
end

function M.set(settings)
  for key, value in pairs(settings) do
    M.settings[key] = value
  end
  apply()
end

hl.on("monitor.focused", apply)
hl.on("monitor.added", apply)
hl.on("monitor.removed", apply)

return M
