-- Compatibility with workspace setups from before each monitor had its own
-- 1-10. `omarchy_global_workspaces` in hyprland.lua wins when it is set.
-- Otherwise a setup that still depends on the old global numbers is kept:
-- a workspace rule that pins one of workspaces 2-10, or workspace 1 on an
-- external connector, or a cloned indicator that still compares its labels
-- to Hyprland's ids. Workspace 1 on the laptop alone is left as it is.
--
-- Keeping the numbers is what leaves Super+number, those indicators, and the
-- saved layout of each workspace consistent. Block numbers (11 and up) are
-- the per-monitor scheme and do not count.

local paths = require("default.hypr.paths")

local M = {}

local STATE_FILE = paths.state_home .. "/omarchy/monitors/global-workspaces"
local published = nil
local detected_result = nil

local function quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

-- True, false, or nil when the user has not chosen.
function M.forced()
  if _G.omarchy_global_workspaces == true then
    return true
  end
  if _G.omarchy_global_workspaces == false then
    return false
  end
  return nil
end

local function strip_comments(text)
  local lines = {}
  for line in (text .. "\n"):gmatch("(.-)\n") do
    local cut = line:find("%-%-")
    if cut then
      line = line:sub(1, cut - 1)
    end
    lines[#lines + 1] = line
  end
  return table.concat(lines, "\n")
end

local function read_file(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end
  local text = file:read("a") or ""
  file:close()
  return text
end

local function files_named(dir, name)
  local found = {}
  local pipe = io.popen("find -L " .. quote(dir) .. " -type f -name " .. quote(name) .. " 2>/dev/null")
  if not pipe then
    return found
  end
  for path in pipe:lines() do
    found[#found + 1] = path
  end
  pipe:close()
  return found
end

-- eDP-1 contains "DP-", so the internal names are excluded before that match.
local function external_connector(monitor)
  if monitor:match("eDP") or monitor:match("LVDS") or monitor:match("DSI") then
    return false
  end
  return monitor:match("DP%-") ~= nil or monitor:match("HDMI") ~= nil or monitor:match("DVI") ~= nil
end

-- Pins of workspaces 1-10. A lone "workspace 1 on the laptop" is the ordinary
-- default and stays on per-monitor numbers. Any other pinned number, or
-- workspace 1 on an external connector, is the old global workflow.
local function pins_need_global(pins)
  for _, pin in ipairs(pins) do
    if pin.number >= 2 or external_connector(pin.monitor) then
      return true
    end
  end
  return false
end

local function add_pin(pins, workspace, monitor)
  local number = tonumber(workspace)
  if number and number >= 1 and number <= 10 and monitor and monitor ~= "" then
    pins[#pins + 1] = { number = number, monitor = monitor }
  end
end

-- A rule that names a workspace and a monitor. The call may span lines and
-- list the fields in either order.
local function rule_pins_global_workspace(text)
  local source = strip_comments(text)
  local pins = {}

  for call in source:gmatch("hl%.workspace_rule%s*%b()") do
    local workspace = call:match('workspace%s*=%s*"(%d+)"')
      or call:match("workspace%s*=%s*'(%d+)'")
      or call:match("workspace%s*=%s*(%d+)")
    local monitor = call:match('monitor%s*=%s*"([^"]+)"') or call:match("monitor%s*=%s*'([^']+)'")
    add_pin(pins, workspace, monitor)
  end

  for number, monitor in source:gmatch('["\'](%d+)%s*,%s*monitor:([^"\']+)["\']') do
    add_pin(pins, number, monitor)
  end

  return pins_need_global(pins)
end

-- An indicator cloned from before per-monitor workspaces labels each button
-- with Hyprland's id and highlights focusedWorkspace. One updated to slots
-- names String(slot) or slotOf and is left on the new numbering.
local function indicator_uses_global_ids(text)
  local compares = text:find("focusedWorkspace.id === modelData", 1, true)
    or text:find("focusedWorkspace.id == modelData", 1, true)
  if not compares then
    return false
  end
  if text:find("String(slot)", 1, true) or text:find("slotOf", 1, true) then
    return false
  end
  return text:find("String(modelData)", 1, true) ~= nil
end

local function cloned_indicator_uses_global_ids()
  local plugins = paths.config_home .. "/omarchy/plugins"
  for _, manifest_path in ipairs(files_named(plugins, "manifest.json")) do
    local manifest = read_file(manifest_path) or ""
    if manifest:find('"clonedFrom"%s*:%s*"omarchy%.workspaces"') then
      local dir = manifest_path:match("^(.*)/") or "."
      for _, qml in ipairs(files_named(dir, "*.qml")) do
        local text = read_file(qml)
        if text and indicator_uses_global_ids(text) then
          return true
        end
      end
    end
  end
  return false
end

function M.detected()
  if detected_result ~= nil then
    return detected_result
  end

  local found = false
  for _, path in ipairs(files_named(paths.config_home .. "/hypr", "*.lua")) do
    local text = read_file(path)
    if text and rule_pins_global_workspace(text) then
      found = true
      break
    end
  end

  if not found then
    found = cloned_indicator_uses_global_ids()
  end

  detected_result = found
  return found
end

function M.enabled()
  local forced = M.forced()
  if forced ~= nil then
    return forced
  end
  return M.detected()
end

-- The bar reads this. "1" keeps global numbers, "0" is each monitor's own.
function M.publish()
  local content = (M.enabled() and "1" or "0") .. "\n"
  if content == published then
    return true
  end

  local dir = paths.state_home .. "/omarchy/monitors"
  local file = io.open(STATE_FILE, "w")
  if not file then
    os.execute("mkdir -p " .. quote(dir))
    file = io.open(STATE_FILE, "w")
  end
  if not file then
    return false
  end

  file:write(content)
  file:close()
  published = content
  return true
end

return M
