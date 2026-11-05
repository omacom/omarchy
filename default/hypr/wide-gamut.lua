-- On Apple Silicon, wide-gamut displays like the Pro Display XDR show sRGB
-- oversaturated. macOS matches colors to the display itself, so the Mac's
-- display controller sends the panel's native gamut, and Asahi's driver has no
-- Colorspace property to tell the display the signal is sRGB instead. Have
-- Hyprland map sRGB into the gamut each display's EDID reports, which changes
-- nothing on an sRGB display. A PC signals sRGB and the display maps it, so
-- doing this there would convert twice and wash the colors out.
--
-- A workaround for the Asahi display driver: remove it once that handles color.
--
-- Every monitor rule goes through hl.monitor, from the config and from the
-- bin/ commands' hyprctl eval alike, and a rule without cm puts the display
-- back on sRGB. So wrap it. A cm chosen in hypr/monitors.lua still wins: the
-- panel's rules name the port and carry no cm, so they take the choice made
-- for that port, for the monitor's description, or for every monitor.

local paths = require("default.hypr.paths")

local chosen = {}

local function chosen_for(output)
  if chosen[output] then
    return chosen[output]
  end

  for _, monitor in ipairs(hl.get_monitors()) do
    if monitor.name == output then
      local description = monitor.description or ""
      for key, cm in pairs(chosen) do
        local prefix = key:match("^desc:(.+)$")
        if prefix and description:sub(1, #prefix) == prefix then
          return cm
        end
      end
    end
  end

  return chosen[""]
end

if o.shell_succeeds(o.shell_quote(paths.omarchy_path .. "/bin/omarchy-hw-aarch64-apple")) then
  local monitor = hl.monitor

  hl.monitor = function(rule)
    if type(rule) == "table" then
      local output = rule.output or ""
      if rule.cm ~= nil then
        chosen[output] = rule.cm
      else
        rule.cm = chosen_for(output) or "edid"
      end
    end

    return monitor(rule)
  end
end
