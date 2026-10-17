-- Omarchy Hyprland setup: helpers, defaults, and current theme overrides.

require("default.hypr.helpers")
local require_optional = require("default.hypr.require_optional")

-- Use Omarchy defaults, but don't edit these directly.
require("default.hypr.autostart")
if _G.omarchy_default_bindings ~= false then
  require("default.hypr.bindings.media")
  require("default.hypr.bindings.clipboard")
  require("default.hypr.bindings.input-method")
  require("default.hypr.bindings.jis")
  require("default.hypr.bindings.tiling")
  require("default.hypr.bindings.utilities")
  require("default.hypr.bindings.dictation")
  require_optional.module("default.hypr.bindings.applications")
end
require("default.hypr.envs")
require("default.hypr.looknfeel")
require("default.hypr.qconsole")
require("default.hypr.input")
-- Let Setup > Config > Touchpad gestures replace ones the user's files add.
-- The settings themselves apply from default.hypr.toggles, after those files.
require("default.hypr.touchpad").watch()
require("default.hypr.windows")
require("default.hypr.dictation-backend")

-- Current theme overrides.
require_optional.module("omarchy.current.theme.hyprland")
