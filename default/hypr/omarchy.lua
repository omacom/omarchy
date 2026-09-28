-- Omarchy Hyprland setup: helpers, defaults, and current theme overrides.

require("default.hypr.helpers")
local require_optional = require("default.hypr.require_optional")

-- Use Omarchy defaults, but don't edit these directly.
-- vmware registers a hyprland.start handler that has to run before
-- autostart's, which launches the shell; handlers fire in registration order,
-- so it cannot sit with nvidia in envs.lua.
require("default.hypr.vmware")
require("default.hypr.autostart")
if _G.omarchy_default_bindings ~= false then
  require("default.hypr.bindings.media")
  require("default.hypr.bindings.clipboard")
  require("default.hypr.bindings.tiling")
  require("default.hypr.bindings.utilities")
  require("default.hypr.bindings.voxtype")
  require_optional.module("default.hypr.bindings.applications")
end
require("default.hypr.envs")
require("default.hypr.looknfeel")
require("default.hypr.qconsole")
require("default.hypr.input")
require("default.hypr.windows")

-- Current theme overrides.
require_optional.module("omarchy.current.theme.hyprland")
