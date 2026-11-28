-- Hyprland keeps one monitor rule per selector and runs a monitor by the latest
-- rule that matches it, whole. A rule naming the same port again is merged into
-- the one before it, so a command that sends only mode, position and scale
-- through hyprctl eval leaves the rest as it was. A rule the config matched by
-- description (desc:) or the catch-all rule gets no such merge: the port-named
-- rule the display panel, the omarchy-hyprland-monitor-* commands and
-- default/hypr/monitor-settings.lua send replaces it outright, and the keys only
-- the config carries, cm, icc, bitdepth, sdr_eotf, vrr, transform, are gone until
-- the next reload. On a laptop that is every lid cycle:
-- omarchy-hyprland-monitor-clamshell brings the panel back with mode, position
-- and scale alone.
--
-- Start every port-named rule from the rule in force for its monitor, as
-- Hyprland does when the names match. A key the rule names itself still wins.
-- Loaded before any monitor rule, so every one of them passes through, from the
-- config and from hyprctl eval alike.

-- Every rule given so far, in the order Hyprland holds them: a rule naming a
-- selector again takes the place at the end, as Hyprland's does.
local rules = {}

local function remember(name, rule)
  for index, entry in ipairs(rules) do
    if entry.name == name then
      table.remove(rules, index)
      break
    end
  end

  rules[#rules + 1] = { name = name, rule = rule }
end

local function description_of(port)
  for _, monitor in ipairs(hl.get_monitors()) do
    if monitor.name == port then
      return monitor.description or ""
    end
  end

  return ""
end

-- The rule Hyprland applies to the monitor on this port: the latest naming the
-- port or a prefix of its description, else the catch-all rule.
local function rule_in_force(port)
  local description = description_of(port)

  for index = #rules, 1, -1 do
    local name = rules[index].name
    local prefix = name:match("^desc:%s*(.-)%s*$")
    if name == port or (prefix and description:sub(1, #prefix) == prefix) then
      return rules[index].rule
    end
  end

  for _, entry in ipairs(rules) do
    if entry.name == "" then
      return entry.rule
    end
  end
end

local monitor = hl.monitor

hl.monitor = function(rule)
  if type(rule) ~= "table" or type(rule.output) ~= "string" then
    return monitor(rule)
  end

  local name = rule.output
  if name ~= "" and not name:match("^desc:") then
    local base = rule_in_force(name)
    if base then
      for key, value in pairs(base) do
        if key ~= "output" and rule[key] == nil then
          rule[key] = value
        end
      end
    end
  end

  local kept = {}
  for key, value in pairs(rule) do
    kept[key] = value
  end
  remember(name, kept)

  return monitor(rule)
end
