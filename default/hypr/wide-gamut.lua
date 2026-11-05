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
-- back on sRGB. So wrap it, leaving a color choice of a rule's own alone.

local paths = require("default.hypr.paths")

if o.shell_succeeds(o.shell_quote(paths.omarchy_path .. "/bin/omarchy-hw-aarch64-apple")) then
  local monitor = hl.monitor

  hl.monitor = function(rule)
    if type(rule) == "table" and rule.cm == nil then
      rule.cm = "edid"
    end

    return monitor(rule)
  end
end
