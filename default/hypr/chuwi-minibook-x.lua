-- Chuwi MiniBook X: turn the sideways-mounted panel landscape, and keep the
-- rotation and tablet mode the hardware services chose across config reloads.
--
-- The DSI panel is natively portrait, so laptop use is transform 3.
-- omarchy-chuwi-minibook-x-autorotate records the current transform as one
-- digit, and omarchy-chuwi-minibook-x-tablet-mode drops a flag while the
-- machine is folded. Both are read as data, never loaded as code.
--
-- Loaded before monitor-settings, so a rotation chosen in the display panel
-- still wins.

local paths = require("default.hypr.paths")

local function read_line(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end
  local line = file:read("*l")
  file:close()
  return line
end

local vendor = read_line("/sys/class/dmi/id/sys_vendor") or ""
if read_line("/sys/class/dmi/id/product_name") ~= "MiniBook X" or not vendor:upper():find("^CHUWI") then
  return
end

local state_dir = paths.home .. "/.local/state/omarchy/chuwi-minibook-x"

local function valid(transform)
  return transform and transform >= 0 and transform <= 3 and transform == math.floor(transform)
end

-- The rotation the display panel saved for this panel, if any. monitor-settings
-- applies it to the display after this file, so touch input has to follow it
-- too or a touch would land in the wrong place.
local function panel_transform()
  if _G.omarchy_monitor_panel_settings == false then
    return nil
  end

  local workspaces = o and o.workspaces
  local identity = workspaces and workspaces.identities()["DSI-1"]
  local file = identity and io.open(paths.state_home .. "/omarchy/monitors/settings", "r")
  if not file then
    return nil
  end

  local transform = nil
  for line in file:lines() do
    local saved, id = line:match("^[^\t]*\t[^\t]*\t[^\t]*\t([^\t]*)\t([^\t]+)$")
    if id == identity then
      transform = tonumber(saved)
    end
  end
  file:close()
  return valid(transform) and transform or nil
end

local transform = tonumber(read_line(state_dir .. "/rotation"))
if not valid(transform) then
  transform = 3
end

hl.monitor({ output = "DSI-1", mode = "preferred", position = "auto", scale = 1.5, transform = transform })
hl.config({ input = { touchdevice = { output = "DSI-1", transform = panel_transform() or transform } } })

local flag = io.open(state_dir .. "/tablet-mode", "r")
if flag then
  flag:close()
  -- The touchpad's nodes go by any of these names; see
  -- omarchy-chuwi-minibook-x-tablet-mode.
  for _, name in ipairs({
    "at-translated-set-2-keyboard",
    "xxxx0000:05-0911:5288",
    "xxxx0000:05-0911:5288-1",
    "xxxx0000:05-0911:5288-touchpad",
    "xxxx0000:05-0911:5288-mouse",
  }) do
    hl.device({ name = name, enabled = false })
  end
end
