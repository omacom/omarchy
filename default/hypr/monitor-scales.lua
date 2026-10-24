-- Re-apply monitor scales saved by omarchy-hyprland-monitor-scaling on top of
-- the rule that governs each monitor, so a scale survives reloads without
-- editing ~/.config/hypr/monitors.lua.
--
-- Hyprland merges a later rule into an earlier one only when both use the same
-- output key, and a rule for a different key replaces it outright. So a saved
-- scale is applied as a full copy of the rule the config set for that monitor,
-- under that rule's own key, with only the scale changed. record() captures the
-- rules as the config sets them (after its loops and locals have run); apply()
-- runs once the user's config is loaded.
--
-- The saved file is data, never Lua: monitor descriptions come from EDID and
-- must not be loaded as code.

local paths = require("default.hypr.paths")

local M = {}

local state_dir = paths.home .. "/.local/state/omarchy/toggles/hypr"
local saved_file = state_dir .. "/monitor-scales"
local monitor_lua = paths.home .. "/.config/hypr/monitors.lua"

local rules = {}

-- Hyprland's Lua state outlives a reload while this module does not, so a
-- wrapper from the previous load may still be installed. Keep the original.
function M.record()
  local current = hl.monitor
  local original = current

  if _G.omarchy_monitor_scales and current == _G.omarchy_monitor_scales.wrapper then
    original = _G.omarchy_monitor_scales.original
  end

  local function wrapper(rule)
    if type(rule) == "table" then
      local copy = {}
      for key, value in pairs(rule) do
        copy[key] = value
      end
      table.insert(rules, copy)
    end

    return original(rule)
  end

  _G.omarchy_monitor_scales = { original = original, wrapper = wrapper }
  hl.monitor = wrapper
end

local function original_monitor()
  if _G.omarchy_monitor_scales then
    return _G.omarchy_monitor_scales.original
  end

  return hl.monitor
end

-- -L follows a symlinked monitors.lua to its target, the file actually edited.
local function modified_at(path)
  local handle = io.popen("stat -L -c %Y " .. "'" .. path:gsub("'", "'\\''") .. "' 2>/dev/null")
  if not handle then
    return nil
  end

  local value = tonumber(handle:read("*l") or "")
  handle:close()
  return value
end

local function matches(output, name, description)
  if output == name then
    return true
  end

  if description ~= "" and output:sub(1, 5) == "desc:" then
    local wanted = output:sub(6)
    return wanted ~= "" and description:sub(1, #wanted) == wanted
  end

  return false
end

-- The last rule naming the monitor wins, as it does in Hyprland; the catch-all
-- only governs a monitor no other rule names.
local function governing_rule(name, description)
  local found
  local catch_all

  for _, rule in ipairs(rules) do
    local output = rule.output
    if type(output) == "string" then
      if output == "" then
        catch_all = rule
      elseif matches(output, name, description) then
        found = rule
      end
    end
  end

  return found, catch_all
end

-- The logical box a rule gives its monitor at a scale, or nil when the rule
-- leaves its size or place to Hyprland ("preferred", "auto", "auto" scale).
local function box(rule, scale)
  scale = tonumber(scale)
  if not scale or scale <= 0 or type(rule.mode) ~= "string" or type(rule.position) ~= "string" then
    return nil
  end

  local width, height = rule.mode:match("^(%d+)x(%d+)")
  local x, y = rule.position:match("^(-?%d+)x(-?%d+)$")
  if not width or not x then
    return nil
  end

  width, height = tonumber(width), tonumber(height)
  -- Odd transforms rotate by 90 or 270 degrees.
  if (tonumber(rule.transform) or 0) % 2 == 1 then
    width, height = height, width
  end

  return { x = tonumber(x), y = tonumber(y), w = width / scale, h = height / scale }
end

local function overlaps(a_start, a_size, b_start, b_size)
  return a_start < b_start + b_size and b_start < a_start + a_size
end

-- A scale changes a monitor's logical size, but its position is fixed, so a
-- monitor that shrinks pulls away from a neighbor on its right or below and
-- leaves a gap the cursor can't cross. Keep it inside the box its own rule
-- gives it, and put it against the side its neighbors are on. Neighbors never
-- move, and a smaller monitor inside its old box can't overlap one. A side
-- with neighbors on both ends can't touch both; it stays put, as before.
local function position_for(rule, scale)
  local old = box(rule, rule.scale)
  local new = box(rule, scale)
  if not old or not new then
    return nil
  end

  local left, right, top, bottom = false, false, false, false
  local seen = {}

  -- The last rule for each output is the one Hyprland uses.
  for index = #rules, 1, -1 do
    local other = rules[index]
    local output = other.output
    if other ~= rule and type(output) == "string" and output ~= "" and output ~= rule.output and not seen[output] then
      seen[output] = true
      local o = box(other, other.scale)
      if o then
        if overlaps(o.y, o.h, old.y, old.h) then
          left = left or math.abs(o.x + o.w - old.x) < 0.5
          right = right or math.abs(o.x - (old.x + old.w)) < 0.5
        end
        if overlaps(o.x, o.w, old.x, old.w) then
          top = top or math.abs(o.y + o.h - old.y) < 0.5
          bottom = bottom or math.abs(o.y - (old.y + old.h)) < 0.5
        end
      end
    end
  end

  local x = (right and not left) and (old.x + old.w - new.w) or old.x
  local y = (bottom and not top) and (old.y + old.h - new.h) or old.y
  if x == old.x and y == old.y then
    return nil
  end

  return string.format("%dx%d", math.floor(x + 0.5), math.floor(y + 0.5))
end

local function apply_scale(scale, name, description)
  local rule, catch_all = governing_rule(name, description)
  local copy = {}

  for key, value in pairs(rule or catch_all or {}) do
    copy[key] = value
  end

  if not rule then
    copy.output = description ~= "" and ("desc:" .. description) or name
  end

  copy.scale = scale
  if rule then
    copy.position = position_for(rule, scale) or copy.position
  end
  original_monitor()(copy)
end

function M.apply()
  local file = io.open(saved_file, "r")
  if not file then
    return
  end

  -- An edit to monitors.lua made after a scale was saved is the newer choice.
  local config_changed_at = modified_at(monitor_lua) or 0

  for line in file:lines() do
    local scale, name, saved_at, description = line:match("^([%d.]+)\t([%w._-]+)\t(%d+)\t([^\t]*)$")
    scale = tonumber(scale)
    saved_at = tonumber(saved_at)

    if scale and scale > 0 and saved_at and saved_at >= config_changed_at then
      apply_scale(scale, name, description)
    end
  end

  file:close()
end

return M
