-- Managed display-panel state. Read as data, not require/dofile: saving it must
-- not reload the whole config, while all normal owner config watches stay live.
local paths = require("default.hypr.paths")
local M = {}

local function read_file(path)
  local handle = io.open(path, "rb")
  if not handle then return nil end
  local data = handle:read("*a")
  handle:close()
  return data
end

function M.apply()
  local handle = io.open(paths.state_home .. "/omarchy/monitor-layout", "rb")
  if not handle then return end
  local version, length, gdk = handle:read("*l"), tonumber(handle:read("*l")), handle:read("*l")
  if version ~= "OMARCHY_MONITOR_LAYOUT_V1" or not length or length < 0 or length > 1048576 or length % 1 ~= 0 then
    handle:close()
    return
  end
  local baseline = length == 0 and "" or handle:read(length)
  if handle:read(1) ~= "\n" or baseline ~= read_file(paths.config_home .. "/hypr/monitors.lua") then
    handle:close()
    return -- The owner's new config takes precedence over previously saved UI state.
  end
  local monitors = {}
  for line in handle:lines() do
    local name, mode, position, scale, transform = line:match("^([%w_.%-]+)\t(%d+x%d+@[%d.]+)\t(%-?%d+x%-?%d+)\t([%d.]+)\t([0-7])$")
    local width, height, rate = (mode or ""):match("^(%d+)x(%d+)@([%d.]+)$")
    width, height, rate = tonumber(width), tonumber(height), tonumber(rate)
    scale, transform = tonumber(scale), tonumber(transform)
    if not name or not width or width < 1 or not height or height < 1 or not rate or rate <= 0 or rate == math.huge or not scale or scale < 1 or scale > 4 or #monitors >= 256 then
      handle:close()
      return
    end
    monitors[#monitors + 1] = { output = name, mode = mode, position = position, scale = scale, transform = transform }
  end
  handle:close()
  for _, monitor in ipairs(monitors) do hl.monitor(monitor) end
  if gdk ~= "-" and gdk:match("^[1-4]$") then hl.env("GDK_SCALE", gdk) end
end

return M
