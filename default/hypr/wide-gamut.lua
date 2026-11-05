-- Apple's wide-gamut displays show sRGB oversaturated on Apple Silicon. macOS
-- matches colors to the display itself, so the Mac's display controller sends
-- the panel's native P3, and Asahi's driver has no Colorspace property to tell
-- the display the signal is sRGB instead. Have Hyprland map sRGB into the gamut
-- the display's EDID reports. A PC signals sRGB and the display maps it, so
-- doing this there would convert twice and wash the colors out.
--
-- A workaround for the Asahi display driver: remove it once that handles color.
--
-- Every monitor rule goes through hl.monitor, from the config and from the
-- bin/ commands' hyprctl eval alike, and a rule without cm puts the display
-- back on sRGB. So wrap it: a rule naming one of these displays gets
-- cm = "edid", and the catch-all rule gets a copy for them by description.

local paths = require("default.hypr.paths")

-- Only displays verified to need it; matched as a description prefix.
local DISPLAYS = { "Apple Computer Inc ProDisplayXDR" }

local function wide_gamut(description)
  for _, prefix in ipairs(DISPLAYS) do
    if description:sub(1, #prefix) == prefix then
      return true
    end
  end

  return false
end

-- Whether a rule's output is one of these displays, by description or by the
-- connector it's plugged into now.
local function names_wide_gamut(output)
  local description = output:match("^desc:(.*)$")
  if description then
    return wide_gamut(description)
  end

  for _, monitor in ipairs(hl.get_monitors()) do
    if monitor.name == output then
      return wide_gamut(monitor.description or "")
    end
  end

  return false
end

local function with_edid(rule, output)
  local copy = {}
  for key, value in pairs(rule) do
    copy[key] = value
  end

  copy.output = output or copy.output
  copy.cm = "edid"
  return copy
end

if o.shell_succeeds(o.shell_quote(paths.omarchy_path .. "/bin/omarchy-hw-aarch64-apple")) then
  local monitor = hl.monitor

  hl.monitor = function(rule)
    -- A color choice of its own wins; a disabled or mirrored output has none.
    if type(rule) ~= "table" or rule.cm ~= nil or rule.disabled or rule.mirror then
      return monitor(rule)
    end

    local output = rule.output or ""
    if output == "" then
      local result = monitor(rule)
      for _, prefix in ipairs(DISPLAYS) do
        monitor(with_edid(rule, "desc:" .. prefix))
      end
      return result
    end

    if names_wide_gamut(output) then
      return monitor(with_edid(rule))
    end

    return monitor(rule)
  end
end
