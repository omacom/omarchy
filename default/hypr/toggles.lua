local paths = require("default.hypr.paths")
local require_all = require("default.hypr.require_all")

local toggles_dir = paths.state_home .. "/omarchy/toggles/hypr"
package.path = toggles_dir .. "/?.lua;" .. package.path

-- touchpad-disabled.lua / touchscreen-disabled.lua were generated Lua in older
-- versions and could carry an injected USB device name. They must never be loaded
-- as code again: exclude them so a not-yet-migrated install cannot execute a
-- leftover payload on reload. The migration recovers the name and deletes them.
local exclude = {
  ["touchpad-disabled"] = true,
  ["touchscreen-disabled"] = true,
}

-- The clamshell rule is Omarchy's own reconciliation, loaded after the monitor
-- settings, so it must not outlast handing monitors to another manager.
if not require("default.hypr.monitor-management")() then
  exclude["internal-monitor-clamshell"] = true
end

require_all.files(toggles_dir, nil, { reload = true, exclude = exclude })

local disabled_input_device = require("default.hypr.disabled-input-device")
disabled_input_device("touchpad")
disabled_input_device("touchscreen")

require("default.hypr.workspace-layouts")

-- After hypr/monitors.lua, so each monitor's mode, position and scale as
-- chosen in the display panel win over a rule written there.
require("default.hypr.monitor-settings")
