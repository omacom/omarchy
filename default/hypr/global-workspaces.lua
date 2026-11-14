-- Global numbering is an explicit choice made before the Omarchy defaults load.
-- User config can contain inactive examples, backups and conditional rules,
-- so reading its source cannot safely choose a numbering scheme for them.

local paths = require("default.hypr.paths")

local M = {}

local STATE_FILE = paths.state_home .. "/omarchy/monitors/global-workspaces"
local published = nil

local function quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

function M.enabled()
  return _G.omarchy_global_workspaces == true
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
