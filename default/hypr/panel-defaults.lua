-- A built-in panel can need monitor settings Hyprland doesn't pick for it on
-- its own: more than 8 bits per channel, or the color space it is made for. Its
-- platform package names them in /usr/share/omarchy-platform/displays.conf, as
--
--   panel <connector> <width>x<height> <key>=<value> ...
--
-- the panel on a connector whose name starts with <connector>, running at that
-- mode (see docs/file-layout.md). Omarchy reads two keys: bitdepth (8 or 10)
-- and cm (a Hyprland color preset for SDR: srgb, dp3, dcip3, adobe, wide or
-- edid). Give each of that panel's rules those settings. Omarchy ships no such
-- line, so without a platform package that names a panel this changes nothing,
-- and other monitors are never touched.
--
-- Every monitor rule goes through hl.monitor, from the config and from the
-- bin/ commands' hyprctl eval alike, and a rule that leaves a setting out puts
-- the output back on Hyprland's default for it. So wrap it, as wide-gamut.lua
-- does for cm. A setting chosen in hypr/monitors.lua still wins, whether for
-- the port, for the monitor's description or for every monitor.
--
-- The catch-all rule names no output, and settings on it would reach external
-- monitors too, so the panel gets a rule of its own: the catch-all's, plus the
-- panel's settings. A panel that arrives after the config has loaded gets it
-- then.

local DISPLAYS_CONF = "/usr/share/omarchy-platform/displays.conf"

-- The keys a panel line can set, each with the values it takes. A key Omarchy
-- doesn't know is skipped, so a newer platform package can add one.
local CM_PRESETS = { srgb = true, dp3 = true, dcip3 = true, adobe = true, wide = true, edid = true }
local KEYS = {
  bitdepth = function(value)
    local bits = tonumber(value)
    if bits == 8 or bits == 10 then
      return bits
    end
  end,
  cm = function(value)
    if CM_PRESETS[value] then
      return value
    end
  end,
}

local function parse_line(line)
  local fields = {}
  for word in (line:gsub("\r", "")):gmatch("%S+") do
    fields[#fields + 1] = word
  end

  if fields[1] ~= "panel" or #fields < 4 then
    return nil
  end

  local connector = fields[2]
  local width, height = fields[3]:match("^(%d+)x(%d+)$")
  if not width or connector:find("/", 1, true) or connector == "." or connector == ".." then
    return nil
  end

  local settings, count = {}, 0
  for i = 4, #fields do
    local key, value = fields[i]:match("^([%w_]+)=(%S+)$")
    if not key then
      return nil
    end
    if KEYS[key] then
      local parsed = KEYS[key](value)
      if parsed == nil then
        return nil
      end
      settings[key] = parsed
      count = count + 1
    end
  end

  if count == 0 then
    return nil
  end

  return { connector = connector, width = tonumber(width), height = tonumber(height), settings = settings }
end

local function read_panels()
  local panels = {}
  local file = io.open(DISPLAYS_CONF, "r")
  if not file then
    return panels
  end

  for line in file:lines() do
    local panel = parse_line(line)
    if panel then
      panels[#panels + 1] = panel
    end
  end

  file:close()
  return panels
end

local panels = read_panels()
if #panels == 0 then
  return
end

local function find_monitor(name)
  for _, monitor in ipairs(hl.get_monitors()) do
    if monitor.name == name then
      return monitor
    end
  end
end

local function panel_settings(monitor)
  if not monitor then
    return nil
  end

  local name = monitor.name or ""
  for _, panel in ipairs(panels) do
    if name:sub(1, #panel.connector) == panel.connector and monitor.width == panel.width
        and monitor.height == panel.height then
      return panel.settings
    end
  end
end

-- Settings chosen in the config, by key, then by rule output: a port,
-- "desc:<prefix>" or "".
local chosen = {}
for key in pairs(KEYS) do
  chosen[key] = {}
end

local function chosen_for(key, output, monitor)
  local by_output = chosen[key]
  if by_output[output] ~= nil then
    return by_output[output]
  end

  local description = monitor and monitor.description or ""
  for rule_output, value in pairs(by_output) do
    local prefix = rule_output:match("^desc:(.+)$")
    if prefix and description:sub(1, #prefix) == prefix then
      return value
    end
  end

  return by_output[""]
end

local function copy(rule)
  local result = {}
  for key, value in pairs(rule) do
    result[key] = value
  end
  return result
end

-- The panel's settings a rule leaves out, from the config's choices or else
-- the platform's.
local function fill(rule, output, monitor, settings)
  for key, value in pairs(settings) do
    if rule[key] == nil then
      local choice = chosen_for(key, output, monitor)
      if choice ~= nil then
        rule[key] = choice
      else
        rule[key] = value
      end
    end
  end
end

local monitor = hl.monitor
local catch_all = nil -- the latest rule for every monitor, without the panel keys
local rules = {} -- the latest rule naming each port, as given
local given = {} -- ports whose panel got its settings

-- The panel's own rule: its latest one, or else the catch-all, plus its settings.
local function give(found)
  local settings = panel_settings(found)
  if not settings or given[found.name] then
    return
  end

  local base = rules[found.name] or catch_all
  if not base then
    return
  end

  local rule = copy(base)
  rule.output = found.name
  fill(rule, found.name, found, settings)
  given[found.name] = true
  monitor(rule)
end

hl.monitor = function(rule)
  if type(rule) ~= "table" then
    return monitor(rule)
  end

  local output = rule.output or ""
  for key in pairs(KEYS) do
    if rule[key] ~= nil then
      chosen[key][output] = rule[key]
    end
  end

  -- Every monitor: the panels follow it, with the settings chosen there if any.
  if output == "" then
    catch_all = copy(rule)
    for key in pairs(KEYS) do
      catch_all[key] = nil
    end
    local result = monitor(rule)
    for _, found in ipairs(hl.get_monitors()) do
      if not rules[found.name] then
        given[found.name] = nil
        give(found)
      end
    end
    return result
  end

  if output:match("^desc:") then
    return monitor(rule)
  end

  rules[output] = copy(rule)
  local found = find_monitor(output)
  local settings = panel_settings(found)
  if settings then
    fill(rule, output, found, settings)
    given[output] = true
  end
  return monitor(rule)
end

hl.on("hyprland.start", function()
  for _, found in ipairs(hl.get_monitors()) do
    give(found)
  end
end)

hl.on("monitor.added", function(added)
  give(added and find_monitor(added.name))
end)
