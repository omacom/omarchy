-- Whether Omarchy manages monitors automatically, which it does until handed to
-- another manager with `omarchy toggle monitor-management off`.

local paths = require("default.hypr.paths")

local OFF_FLAG = paths.home .. "/.local/state/omarchy/toggles/monitor-management-off"

return function()
  local flag = io.open(OFF_FLAG, "r")
  if flag then
    flag:close()
    return false
  end

  return true
end
