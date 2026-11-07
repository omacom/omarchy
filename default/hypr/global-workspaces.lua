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

-- Long comments use the same arbitrary number of equals signs as long
-- strings. Quoted comment markers must survive (for example in monitor names).
local function long_string_end(text, start)
  local equals = text:match("^%[(=*)%[", start)
  if equals == nil then return nil end
  local _, last = text:find("]" .. equals .. "]", start + #equals + 2, true)
  return last or #text
end

local function strip_comments(text)
  local parts = {}
  local index = 1
  while index <= #text do
    local char = text:sub(index, index)
    if char == '"' or char == "'" then
      local last = index + 1
      while last <= #text do
        local next_char = text:sub(last, last)
        if next_char == "\\" then
          last = last + 2
        elseif next_char == char then
          last = last + 1
          break
        else
          last = last + 1
        end
      end
      parts[#parts + 1] = text:sub(index, last - 1)
      index = last
    elseif text:sub(index, index + 1) == "--" then
      local last = long_string_end(text, index + 2)
      index = last and last + 1 or (text:find("\n", index + 2, true) or (#text + 1))
      parts[#parts + 1] = " "
    else
      local last = long_string_end(text, index) or index
      parts[#parts + 1] = text:sub(index, last)
      index = last + 1
    end
  end
  return table.concat(parts)
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
  local pipe = io.popen("find -L " .. quote(dir) .. " -name '.*' -prune -o -type f -name " .. quote(name) .. " -print 2>/dev/null")
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

-- jq is part of the base install. Parse shell.json rather than searching for
-- ids in text, so an installed but inactive clone cannot change shortcuts.
local function json_lines(path, filter)
  local lines = {}
  local pipe = io.popen("jq -r " .. quote(filter) .. " " .. quote(path) .. " 2>/dev/null")
  if not pipe then return lines end
  for line in pipe:lines() do lines[#lines + 1] = line end
  if not pipe:close() then return {} end
  return lines
end

local function cloned_indicator_uses_global_ids()
  local config = paths.config_home .. "/omarchy"
  local active = json_lines(config .. "/shell.json", [=[
    select(.version == 1) |
    (.disabledPlugins // []) as $disabled |
    [.bar.layout // {} | .left, .centerBegin, .center, .centerEnd, .right, .tray | .[]? |
      (if type == "object" then .id else . end) |
      select(type == "string") |
      select(. as $id | $disabled | index($id) == null)] | unique[]
  ]=])

  for _, id in ipairs(active) do
    -- PluginRegistry discovers one directory per id. Do not descend into the
    -- hidden backups kept by plugin-remove, even if shell.json is stale.
    if id:match("^[%w][%w._-]*$") then
      local dir = config .. "/plugins/" .. id
      local entrypoints = json_lines(dir .. "/manifest.json", 'select(.id == "' .. id .. [[" and
        .schemaVersion == 1 and has("name") and has("version") and
        (.kinds | type) == "array" and (.kinds | index("bar-widget")) != null and
        .omarchy.clonedFrom == "omarchy.workspaces" and (.entryPoints | type) == "object" and
        all(.entryPoints[]; type == "string" and length > 0 and
          (startswith("/") | not) and (contains("..") | not))) | .entryPoints.barWidget | select(type == "string")]])
      for _, entrypoint in ipairs(entrypoints) do
        -- Inspect the loaded widget, not unused QML copied alongside it (a
        -- full-bar clone also carries dormant copies of the built-in widgets).
        if entrypoint ~= "" and entrypoint:sub(1, 1) ~= "/" and not entrypoint:find("..", 1, true) then
          local text = read_file(dir .. "/" .. entrypoint)
          if text and indicator_uses_global_ids(text) then return true end
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
