-- Hyprland gives a monitor one rule: the newest that names its port or its
-- description, else the one for every monitor. hl.monitor adds to a rule of
-- the same name, but a port's first rule starts from Hyprland's defaults, not
-- from the rule the monitor was running on.
--
-- The monitor panel's saved choices and its commands name the port. So the
-- first of them for a monitor dropped whatever hypr/monitors.lua sets for its
-- description or for every monitor that the panel doesn't cover, such as
-- 10-bit color, cm or vrr: at the next reload, or at once when a scale was
-- picked.
--
-- Every monitor rule goes through hl.monitor, from the config and from the
-- bin/ commands' hyprctl eval alike. So wrap it and keep what each rule holds.
-- The rules in hypr/monitors.lua are taken as written. After it, a port's
-- first rule carries over the rule its monitor had: what the new rule sets
-- wins, and the rest stays.

local M = {}

-- What each rule holds, by output name, and the names from oldest to newest.
local rules = {}
local names = {}
local carrying_over = false

local function names_port(output)
  return output ~= "" and not output:match("^desc:")
end

-- The rule Hyprland gives the monitor on a port while no rule names the port.
-- Nothing for a port with no monitor on it: which rule it had is unknown.
local function rule_before(port)
  for _, monitor in ipairs(hl.get_monitors()) do
    if monitor.name == port then
      local description = monitor.description or ""
      for index = #names, 1, -1 do
        local prefix = names[index]:match("^desc:%s*(.-)%s*$")
        if prefix and description:sub(1, #prefix) == prefix then
          return rules[names[index]]
        end
      end

      return rules[""]
    end
  end
end

local function remember(rule)
  local held = rules[rule.output]

  if held then
    for index, name in ipairs(names) do
      if name == rule.output then
        table.remove(names, index)
        break
      end
    end
  else
    held = {}
    rules[rule.output] = held
  end

  -- Hyprland moves a rule it updates to the end, where it is the newest.
  names[#names + 1] = rule.output

  for field, value in pairs(rule) do
    held[field] = value
  end
end

local monitor = hl.monitor

hl.monitor = function(rule)
  if type(rule) == "table" and type(rule.output) == "string" then
    if carrying_over and not rules[rule.output] and names_port(rule.output) then
      for field, value in pairs(rule_before(rule.output) or {}) do
        if rule[field] == nil then
          rule[field] = value
        end
      end
    end

    remember(rule)
  end

  return monitor(rule)
end

-- Called once hypr/monitors.lua has loaded.
function M.carry_over()
  carrying_over = true
end

return M
