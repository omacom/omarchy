-- On Apple Silicon, Apple's wide-gamut displays show sRGB oversaturated: the
-- built-in panel, the Pro Display XDR and the Studio Display. macOS matches
-- colors to them itself, so the Mac's display controller sends their native
-- gamut, and Asahi's driver has no Colorspace property to say the signal is
-- sRGB. Have Hyprland map sRGB into the gamut their EDID reports. Other
-- monitors stay on sRGB: they map the signal themselves, and mapping it twice
-- washes the colors out.
--
-- A workaround for the Asahi display driver: remove it once that handles color.
--
-- Every monitor rule goes through hl.monitor, from the config and from the
-- bin/ commands' hyprctl eval alike, and a rule without cm puts the display
-- back on sRGB. So wrap it. The rule for every monitor ("") can't pick a cm
-- per display, so it's copied for the built-in port and the Apple displays'
-- descriptions, which covers ones plugged in later. Hyprland uses the last
-- matching rule, so rules naming a monitor are replayed after the copies and
-- still win. A cm chosen in hypr/monitors.lua wins too: the panel's rules name
-- the port and carry no cm, so they take the choice made for that port, for
-- the monitor's description, or for every monitor.

local paths = require("default.hypr.paths")

-- libdisplay-info names Apple's EDID vendor "Apple Computer Inc"; "Apple Inc"
-- covers a display that reports the newer name.
local apple_displays = {
  "Apple Computer Inc ProDisplayXDR",
  "Apple Computer Inc StudioDisplay",
  "Apple Inc ProDisplayXDR",
  "Apple Inc StudioDisplay",
}

local function starts_with(text, prefix)
  return text:sub(1, #prefix) == prefix
end

local function wide_gamut(output, description)
  if output:match("^eDP%-") then
    return true
  end

  local desc = output:match("^desc:(.+)$")
  for _, prefix in ipairs(apple_displays) do
    if starts_with(description, prefix) or (desc and starts_with(desc, prefix)) then
      return true
    end
  end

  return false
end

local function built_in_ports()
  local ports = {}
  for _, monitor in ipairs(hl.get_monitors()) do
    if (monitor.name or ""):match("^eDP%-") then
      ports[#ports + 1] = monitor.name
    end
  end
  if #ports == 0 then
    ports[1] = "eDP-1"
  end
  return ports
end

local function copy(rule, output, cm)
  local copied = {}
  for key, value in pairs(rule) do
    copied[key] = value
  end
  copied.output, copied.cm = output, cm
  return copied
end

local chosen, named = {}, {}

local function cm_for(output)
  if chosen[output] then
    return chosen[output]
  end

  local description = ""
  for _, monitor in ipairs(hl.get_monitors()) do
    if monitor.name == output then
      description = monitor.description or ""
      for key, cm in pairs(chosen) do
        local prefix = key:match("^desc:(.+)$")
        if prefix and starts_with(description, prefix) then
          return cm
        end
      end
    end
  end

  if chosen[""] then
    return chosen[""]
  end
  return wide_gamut(output, description) and "edid" or nil
end

if o.shell_succeeds(o.shell_quote(paths.omarchy_path .. "/bin/omarchy-hw-aarch64-apple")) then
  local monitor = hl.monitor

  local function apply(rule)
    local output = rule.output or ""
    if rule.cm ~= nil then
      chosen[output] = rule.cm
      return monitor(rule)
    end
    return monitor(copy(rule, rule.output, cm_for(output)))
  end

  hl.monitor = function(rule)
    if type(rule) ~= "table" then
      return monitor(rule)
    end

    local output = rule.output or ""
    if output ~= "" then
      for i, earlier in ipairs(named) do
        if (earlier.output or "") == output then
          table.remove(named, i)
          break
        end
      end
      named[#named + 1] = copy(rule, rule.output, rule.cm)
      return apply(rule)
    end

    local result = apply(rule)
    for _, port in ipairs(built_in_ports()) do
      monitor(copy(rule, port, rule.cm or "edid"))
    end
    for _, prefix in ipairs(apple_displays) do
      monitor(copy(rule, "desc:" .. prefix, rule.cm or "edid"))
    end
    for _, earlier in ipairs(named) do
      apply(earlier)
    end
    return result
  end
end
