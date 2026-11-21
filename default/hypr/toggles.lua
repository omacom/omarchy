local paths = require("default.hypr.paths")
local require_all = require("default.hypr.require_all")

local toggles_dir = paths.state_home .. "/omarchy/toggles/hypr"
package.path = toggles_dir .. "/?.lua;" .. package.path

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

-- Windows Drag Maximize marked for the dock keep their marks across a reload
-- that leaves it off, with nothing left to clear them.
local floating_bounds = package.loaded["default.hypr.floating-bounds"]
if not (floating_bounds and floating_bounds.drop_maximize) then
  require("default.hypr.floating-marks").clear()
end

local disabled_input_device = require("default.hypr.disabled-input-device")
disabled_input_device("touchpad")
disabled_input_device("touchscreen")

require("default.hypr.workspace-layouts")

-- After hypr/monitors.lua, so each monitor's mode, position and scale as
-- chosen in the display panel win over a rule written there.
require("default.hypr.monitor-settings")
