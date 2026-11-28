-- The toggle command builds a plugin for this compositor ABI before enabling it.
local paths = require("default.hypr.paths")
local file = io.open(paths.state_home .. "/omarchy/float-snap/current", "r")
if file then
  local plugin = file:read("*l")
  file:close()
  if plugin and plugin ~= "" then
    hl.plugin.load(plugin)
  end
end
