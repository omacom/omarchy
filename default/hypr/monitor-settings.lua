-- Each monitor's mode, position, scale and rotation as chosen in the display
-- panel, kept by the physical monitor rather than the port it's plugged into.
--
-- They live in a state file, one line per monitor ever set: its mode, position,
-- scale and transform, any of them empty when never chosen, then its identity (make,
-- model and serial, as monitor-workspaces names it). A dock renames its
-- connectors between plugs, so a rule naming DP-1 would hand one monitor's
-- mode to whatever turns up on that port next. omarchy-hyprland-monitor-persist
-- writes the file; nothing here writes it.
--
-- Applied while the config loads, after hypr/monitors.lua, so a choice made in
-- the panel wins over a rule written there and a reload settles on it in one
-- go. Applied again when a monitor arrives, skipping one that already runs as
-- saved, so plugging it back in doesn't reconfigure it for nothing.
--
-- Setting omarchy_monitor_panel_settings = false in hypr/monitors.lua leaves
-- that file alone in charge, GDK_SCALE included.

local paths = require("default.hypr.paths")

local STATE_FILE = paths.state_home .. "/omarchy/monitors/settings"

local M = {}

local function load()
  local settings = {}
  if _G.omarchy_monitor_panel_settings == false then
    return settings
  end

  local file = io.open(STATE_FILE, "r")
  if not file then
    return settings
  end

  -- Mode, position, scale and transform, then the identity; lines saved before
  -- rotation was saved lack the transform.
  for line in file:lines() do
    local mode, position, scale, transform, identity = line:match("^([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]+)$")
    if not identity then
      mode, position, scale, identity = line:match("^([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]+)$")
    end
    if identity then
      settings[identity] = {
        mode = mode ~= "" and mode or nil,
        position = position ~= "" and position or nil,
        scale = tonumber(scale),
        transform = tonumber(transform),
      }
    end
  end

  file:close()
  return settings
end

-- Whether a monitor already runs at its saved mode, position and scale.
local function matches(monitor, saved)
  if saved.scale and math.abs((monitor.scale or 0) - saved.scale) > 0.001 then
    return false
  end

  if saved.position then
    local x, y = saved.position:match("^(-?%d+)x(-?%d+)$")
    if tonumber(x) ~= monitor.x or tonumber(y) ~= monitor.y then
      return false
    end
  end

  if saved.mode then
    local width, height, rate = saved.mode:match("^(%d+)x(%d+)@?([%d.]*)$")
    if tonumber(width) ~= monitor.width or tonumber(height) ~= monitor.height then
      return false
    end
    if rate ~= "" and math.abs((monitor.refresh_rate or 0) - tonumber(rate)) > 0.5 then
      return false
    end
  end

  if saved.transform and saved.transform ~= (monitor.transform or 0) then
    return false
  end

  return true
end

-- Only what was chosen: hl.monitor updates the connector's existing rule, so
-- anything never set in the panel keeps what hypr/monitors.lua gives it.
local function rule(name, saved)
  return { output = name, mode = saved.mode, position = saved.position, scale = saved.scale, transform = saved.transform }
end

-- GDK_SCALE is one value for the whole session, so it follows the lowest
-- monitor scale: XWayland apps end up a little small on denser screens rather
-- than oversized on the others. GTK only honors integers, so round it. Left to
-- hypr/monitors.lua until a scale has been chosen here.
local function set_gdk_scale(settings, identities)
  local lowest = nil
  local chosen = false

  for _, monitor in ipairs(hl.get_monitors()) do
    if not monitor.is_mirror then
      local saved = settings[identities[monitor.name]]
      chosen = chosen or (saved ~= nil and saved.scale ~= nil)
      local scale = (saved and saved.scale) or monitor.scale
      if scale and (not lowest or scale < lowest) then
        lowest = scale
      end
    end
  end

  if chosen and lowest then
    hl.env("GDK_SCALE", tostring(math.max(1, math.floor(lowest + 0.5))))
  end
end

-- Apply the saved settings of the connected monitors, or just of `only`. While
-- the config loads every one is applied, since the rules just read from
-- hypr/monitors.lua would otherwise win; afterwards one already running as
-- saved is left alone.
function M.apply(loading, only)
  local settings = load()
  if next(settings) == nil then
    return
  end

  local identities = o.workspaces.identities()
  for _, monitor in ipairs(hl.get_monitors()) do
    local saved = settings[identities[monitor.name]]
    if not monitor.is_mirror and saved and (not only or monitor.name == only)
        and (loading or not matches(monitor, saved)) then
      hl.monitor(rule(monitor.name, saved))
    end
  end

  set_gdk_scale(settings, identities)
end

-- Bring GDK_SCALE up to date after a save, without touching any monitor: the
-- command that saved has already applied the change, in the order it chose.
function M.update_gdk_scale()
  local settings = load()
  if next(settings) ~= nil then
    set_gdk_scale(settings, o.workspaces.identities())
  end
end

M.apply(true)

hl.on("hyprland.start", function()
  M.apply(false)
end)

hl.on("monitor.added", function(monitor)
  M.apply(false, monitor and monitor.name)
end)

o.monitor_settings = M

return M
