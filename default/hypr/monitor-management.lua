-- Whether Omarchy manages monitors automatically, or has handed them to another
-- manager with `omarchy toggle monitor-management off`.

local paths = require("default.hypr.paths")

local FLAG = paths.home .. "/.local/state/omarchy/toggles/monitor-management"

return function()
  local flag = io.open(FLAG, "r")
  if flag then
    flag:close()
    return true
  end

  return false
end
