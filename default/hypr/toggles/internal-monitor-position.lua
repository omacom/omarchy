-- A remembered arrangement must pin the externals too: leaving one on auto
-- lets Hyprland move it after the returning panel. State is data, never Lua.
-- The record is a version, internal connector and output count, followed by
-- tab-separated monitor rows and the exact monitors.lua contents from docking.
local dir = os.getenv("HOME") .. "/.local/state/omarchy/toggles/hypr/"
local function discard()
  os.remove(dir .. "internal-monitor-position")
  os.remove(dir .. "internal-monitor-position.lua")
  os.remove(dir .. "internal-monitor-layout")
end

for _, flag in ipairs({ "internal-monitor-clamshell", "internal-monitor-disable", "internal-monitor-mirror" }) do
  local file = io.open(dir .. flag .. ".lua")
  if file then
    file:close()
    return discard()
  end
end

-- Bash arms this record only after the clamshell reload and scale sync.
-- A pending capture uses a different path, invisible to an earlier toggle.
local file = io.open(dir .. "internal-monitor-position", "rb")
local restoring = file ~= nil
if not file then file = io.open(dir .. "internal-monitor-layout", "rb") end
if not file then return discard() end
local version, internal, count = file:read("*l"), file:read("*l"), tonumber(file:read("*l"))
local function invalid()
  file:close()
  return discard()
end
if version ~= "2" or not internal or not internal:match("^[%w._-]+$")
  or not count or count % 1 ~= 0 or count < 2 or count > 64 then return invalid() end

local expected, names = {}, {}
local keys = { "name", "serial", "description", "width", "height", "scale", "transform", "x", "y", "refresh_rate" }
for _ = 1, count do
  local line = file:read("*l")
  if not line then return invalid() end
  local fields = {}
  for field in (line .. "\t"):gmatch("(.-)\t") do fields[#fields + 1] = field end
  if #fields ~= #keys or not fields[1]:match("^[%w._-]+$") or names[fields[1]] then return invalid() end
  local saved = {}
  for i, key in ipairs(keys) do
    saved[key] = i <= 3 and fields[i] or tonumber(fields[i])
    if saved[key] == nil then return invalid() end
    if i > 3 and (saved[key] ~= saved[key] or math.abs(saved[key]) == math.huge) then return invalid() end
  end
  if saved.width <= 0 or saved.width > 2147483647 or saved.width % 1 ~= 0
    or saved.height <= 0 or saved.height > 2147483647 or saved.height % 1 ~= 0
    or saved.scale <= 0 or saved.refresh_rate <= 0 or saved.transform % 1 ~= 0 or saved.transform < 0 or saved.transform > 7
    or saved.x % 1 ~= 0 or saved.y % 1 ~= 0 or math.abs(saved.x) > 2147483647 or math.abs(saved.y) > 2147483647 then return invalid() end
  expected[#expected + 1], names[saved.name] = saved, true
end
if not names[internal] then return invalid() end
local config = file:read("*a")
file:close()
local current = io.open(os.getenv("HOME") .. "/.config/hypr/monitors.lua", "rb")
if not current then return discard() end
local contents = current:read("*a")
current:close()
if contents ~= config then return discard() end

local function identity(value)
  return (value or ""):gsub("[^A-Za-z0-9._:-]", "_")
end
local actual = hl.get_monitors()
if #actual ~= #expected then return discard() end
for _, saved in ipairs(expected) do
  local monitor = hl.get_monitor(saved.name)
  if not monitor or identity(monitor.serial) ~= saved.serial or identity(monitor.description) ~= saved.description then return discard() end
  for _, key in ipairs({ "width", "height", "transform" }) do
    if monitor[key] ~= saved[key] then return discard() end
  end
  -- IPC rounds fractional scales; Lua exposes the compositor's full float.
  if math.abs(monitor.scale - saved.scale) >= 0.001
    or math.abs(monitor.refresh_rate - saved.refresh_rate) >= 0.001
    or (not restoring and (monitor.x ~= saved.x or monitor.y ~= saved.y)) then return discard() end
end

-- Only restore arrangements whose output rectangles do not overlap. Round
-- live layout sizes just as Hyprland does, including fractional scales.
local function size(monitor)
  local w, h = monitor.width, monitor.height
  if monitor.transform % 2 == 1 then w, h = h, w end
  return math.floor(w / monitor.scale + 0.5), math.floor(h / monitor.scale + 0.5)
end
for i, left in ipairs(expected) do
  local lw, lh = size(left)
  for j = i + 1, #expected do
    local right = expected[j]
    local rw, rh = size(right)
    if left.x < right.x + rw and right.x < left.x + lw
      and left.y < right.y + rh and right.y < left.y + lh then return discard() end
  end
end
for _, saved in ipairs(expected) do
  hl.monitor({ output = saved.name, position = string.format("%dx%d", saved.x, saved.y), scale = saved.scale,
    mode = string.format("%dx%d@%.5f", saved.width, saved.height, saved.refresh_rate), transform = saved.transform })
end
if restoring then os.rename(dir .. "internal-monitor-position", dir .. "internal-monitor-layout") end
