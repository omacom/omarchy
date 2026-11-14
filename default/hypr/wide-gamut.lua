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

-- The area of the primaries triangle in an EDID's chromaticity block (sRGB is
-- about 0.11). A panel that reports no primaries has no gamut to map into:
-- "edid" then collapses the output to black. Unreadable EDIDs count as usable.
local function edid_has_gamut(name)
  if not name:match("^[%w%-]+$") then
    return true
  end

  local pipe = io.popen("cat /sys/class/drm/card*-" .. name .. "/edid 2>/dev/null", "r")
  if not pipe then
    return true
  end
  local edid = pipe:read("a")
  pipe:close()
  if #edid < 35 then
    return true
  end

  local function coord(msb_offset, lsb_offset, shift)
    local msb = edid:byte(msb_offset + 1)
    local lsb = (edid:byte(lsb_offset + 1) // 2 ^ shift) % 4
    return (msb * 4 + lsb) / 1024
  end

  local rx, ry = coord(27, 25, 6), coord(28, 25, 4)
  local gx, gy = coord(29, 25, 2), coord(30, 25, 0)
  local bx, by = coord(31, 26, 6), coord(32, 26, 4)
  return math.abs(rx * (gy - by) + gx * (by - ry) + bx * (ry - gy)) / 2 > 0.01
end

-- Whether every monitor a rule covers has a gamut ("" covers all of them).
local function gamut_for_rule(output)
  for _, monitor in ipairs(hl.get_monitors()) do
    if (output == "" or monitor.name == output) and not edid_has_gamut(monitor.name) then
      return false
    end
  end
  return true
end

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
        rule.cm = chosen_for(output) or (gamut_for_rule(output) and "edid" or nil)
      end
    end

    return monitor(rule)
  end
end
