local paths = require("default.hypr.paths")

local M = {}
local modes = {}
local file = io.open(paths.state_home .. "/omarchy/workspace-layout-cycle", "r")

if file then
  for mode in file:lines() do
    if mode == "dwindle" or mode == "scrolling" or mode == "floating" then
      modes[mode] = true
    end
  end
  file:close()
end

for _, mode in ipairs({ "dwindle", "scrolling", "floating" }) do
  if modes[mode] then
    M.fallback = mode
    break
  end
end

function M.allows(mode)
  return not M.fallback or modes[mode] == true
end

return M
