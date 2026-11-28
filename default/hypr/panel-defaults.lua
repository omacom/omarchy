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

-- Rules count in the order they are given: Hyprland takes the latest one
-- naming a monitor, by port or by description.
local order = 0

-- The description prefix a rule output names, trimmed as Hyprland trims it.
local function desc_prefix(output)
  local prefix = output:match("^desc:(.*)$")
  if prefix then
    return prefix:match("^%s*(.-)%s*$")
  end
end

local function describes(prefix, monitor)
  local description = monitor and monitor.description or ""
  return description:sub(1, #prefix) == prefix
end

-- Settings chosen in the config, by key, then by rule output: a port,
-- "desc:<prefix>" or "", each with the order it was chosen in.
local chosen = {}
for key in pairs(KEYS) do
  chosen[key] = {}
end

local function chosen_for(key, output, monitor)
  local by_output = chosen[key]
  if by_output[output] then
    return by_output[output].value
  end

  local latest = nil
  for rule_output, choice in pairs(by_output) do
    local prefix = desc_prefix(rule_output)
    if prefix and describes(prefix, monitor) and (not latest or choice.order > latest.order) then
      latest = choice
    end
  end
  if latest then
    return latest.value
  end

  return by_output[""] and by_output[""].value
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
local rules = {} -- the latest rule naming each port, as given, with its order
local desc_rules = {} -- the rules naming a description prefix, latest last, as given
local given = {} -- ports whose panel got its settings

-- The latest rule naming a monitor by its description, if any.
local function desc_rule_for(found)
  for i = #desc_rules, 1, -1 do
    if describes(desc_rules[i].prefix, found) then
      return desc_rules[i]
    end
  end
end

-- The panel's own rule: the latest one naming it, by port or description, or
-- else the catch-all, plus its settings.
local function give(found)
  local settings = panel_settings(found)
  if not settings or given[found.name] then
    return
  end

  local by_port, by_desc = rules[found.name], desc_rule_for(found)
  local base = catch_all
  if by_port and (not by_desc or by_port.order > by_desc.order) then
    base = by_port.rule
  elseif by_desc then
    base = by_desc.rule
  end
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
  local prefix = desc_prefix(output)
  if prefix then
    output = "desc:" .. prefix
  end

  order = order + 1
  for key in pairs(KEYS) do
    if rule[key] ~= nil then
      chosen[key][output] = { value = rule[key], order = order }
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

  -- A rule naming the panel by its description takes over from any earlier
  -- one for it, by port too, and replaces its settings in Hyprland. It may
  -- match external displays as well, so it goes on unchanged and the panel
  -- gets its own rule after it, as with the catch-all.
  if prefix then
    for i = #desc_rules, 1, -1 do
      if desc_rules[i].prefix == prefix then
        table.remove(desc_rules, i)
      end
    end
    desc_rules[#desc_rules + 1] = { prefix = prefix, rule = copy(rule), order = order }
    local result = monitor(rule)
    for _, found in ipairs(hl.get_monitors()) do
      if describes(prefix, found) then
        given[found.name] = nil
        give(found)
      end
    end
    return result
  end

  rules[output] = { rule = copy(rule), order = order }
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
