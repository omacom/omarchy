-- On Apple Silicon, Apple's wide-gamut displays show sRGB oversaturated: the
-- built-in panel, the Pro Display XDR and the Studio Display. macOS matches
-- colors to them itself, so the Mac's display controller sends their native
-- gamut, and Asahi's driver has no Colorspace property to say the signal is
-- sRGB. Have Hyprland map sRGB into the gamut their EDID reports. Other
-- monitors get sRGB, Hyprland's default: they map the signal themselves, and
-- mapping it twice washes the colors out.
--
-- A workaround for the Asahi display driver: remove it once that handles color.
--
-- Every monitor rule goes through hl.monitor, from the config and from the
-- bin/ commands' hyprctl eval alike, so wrap it. The rule for every monitor
-- ("") can't pick a cm per display, so it's copied for the built-in port and
-- the Apple displays' descriptions, which covers ones plugged in later.
-- Hyprland uses the last matching rule, so rules naming a monitor are
-- replayed after the copies and still win, and they're checked again when a
-- monitor they match is plugged in. A cm chosen in hypr/monitors.lua wins too:
-- the panel's rules name the port and carry no cm, so they take the choice
-- made for that port, for the monitor's description, or for every monitor.

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

local chosen, named, given = {}, {}, {}

-- The connected monitors a rule is for: the one on its port, or every one
-- whose description starts with the rule's.
local function monitors_for(output)
  local prefix = output:match("^desc:(.+)$")
  local found = {}
  for _, monitor in ipairs(hl.get_monitors()) do
    local description = monitor.description or ""
    if monitor.name == output or (prefix and starts_with(description, prefix)) then
      found[#found + 1] = { name = monitor.name or "", description = description }
    end
  end
  return found
end

-- Returns "srgb" rather than nothing for other displays: hl.monitor updates
-- the port's existing rule, so leaving cm out would keep an edid given to the
-- display that was there before.
local function cm_for(output)
  if chosen[output] then
    return chosen[output]
  end

  -- A port rule takes the cm chosen for its monitor's description. A
  -- description rule doesn't borrow one: it can cover other displays too.
  local matched = monitors_for(output)
  local by_port = not output:match("^desc:")
  for _, monitor in ipairs(by_port and matched or {}) do
    for key, cm in pairs(chosen) do
      local prefix = key:match("^desc:(.+)$")
      if prefix and starts_with(monitor.description, prefix) then
        return cm
      end
    end
  end

  if chosen[""] then
    return chosen[""]
  end

  if wide_gamut(output, "") then
    return "edid"
  end
  for _, monitor in ipairs(matched) do
    if wide_gamut(monitor.name, monitor.description) then
      return "edid"
    end
  end
  return "srgb"
end

if o.shell_succeeds(o.shell_quote(paths.omarchy_path .. "/bin/omarchy-hw-aarch64-apple")) then
  local monitor = hl.monitor

  local function apply(rule)
    local output = rule.output or ""
    if rule.cm ~= nil then
      chosen[output] = rule.cm
      return monitor(rule)
    end
    given[output] = cm_for(output)
    return monitor(copy(rule, rule.output, given[output]))
  end

  hl.monitor = function(rule)
    if type(rule) ~= "table" then
      return monitor(rule)
    end

    local output = rule.output or ""
    if output ~= "" then
      -- hl.monitor merges into the output's existing rule, so the replay does
      -- too: an earlier mode survives a later call that sets only the scale.
      local entry = {}
      for i, earlier in ipairs(named) do
        if earlier.output == output then
          entry = table.remove(named, i)
          break
        end
      end
      for key, value in pairs(rule) do
        entry[key] = value
      end
      named[#named + 1] = entry
      return apply(entry)
    end

    local result = apply(rule)
    for _, port in ipairs(built_in_ports()) do
      monitor(copy(rule, port, rule.cm or chosen[""] or "edid"))
    end
    for _, prefix in ipairs(apple_displays) do
      monitor(copy(rule, "desc:" .. prefix, rule.cm or chosen[""] or "edid"))
    end
    for _, earlier in ipairs(named) do
      apply(earlier)
    end
    return result
  end

  -- A rule loaded before its monitor was plugged in couldn't see which
  -- display it was for, so check again when one arrives. Hyprland moves a
  -- re-sent rule to the end, so once one changes, every rule after it is
  -- re-sent too and the order that decides which wins stays the same.
  hl.on("monitor.added", function(added)
    local name = added and added.name
    local description = ""
    for _, monitor in ipairs(hl.get_monitors()) do
      if monitor.name == name then
        description = monitor.description or ""
      end
    end
    local changed = false
    for _, rule in ipairs(named) do
      local prefix = rule.output:match("^desc:(.+)$")
      local matches = rule.output == name or (prefix and starts_with(description, prefix))
      if changed or (matches and rule.cm == nil and cm_for(rule.output) ~= given[rule.output]) then
        changed = true
        apply(rule)
      end
    end
  end)
end
