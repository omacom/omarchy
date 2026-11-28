local paths = require("default.hypr.paths")
local require_all = require("default.hypr.require_all")

local toggles_dir = paths.state_home .. "/omarchy/toggles/hypr"
package.path = toggles_dir .. "/?.lua;" .. package.path

-- Display-panel preferences override the normal layout. The no-gaps toggle
-- below can temporarily turn them off without losing the saved sizes.
local window_gaps = {}
for _, side in ipairs({ "in", "out" }) do
  local file = io.open(paths.state_home .. "/omarchy/window-gaps-" .. side, "r")
  if file then
    local text = file:read("*l")
    file:close()
    local value = text and text:match("^%d%d?$") and tonumber(text)
    if value and value <= 64 then
      window_gaps["general.gaps_" .. side] = value
    end
  end
end
if next(window_gaps) then
  hl.config(window_gaps)
end

-- touchpad-disabled.lua / touchscreen-disabled.lua were generated Lua in older
-- versions and could carry an injected USB device name. They must never be loaded
-- as code again: exclude them so a not-yet-migrated install cannot execute a
-- leftover payload on reload. The migration recovers the name and deletes them.
require_all.files(toggles_dir, nil, {
  reload = true,
  exclude = {
    ["touchpad-disabled"] = true,
    ["touchscreen-disabled"] = true,
  },
})

local disabled_input_device = require("default.hypr.disabled-input-device")
disabled_input_device("touchpad")
disabled_input_device("touchscreen")

require("default.hypr.workspace-layouts")

-- After hypr/monitors.lua, so each monitor's mode, position and scale as
-- chosen in the display panel win over a rule written there.
require("default.hypr.monitor-settings")
