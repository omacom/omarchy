-- Touchpad gestures. See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
--
-- The defaults are listed in default/hypr/touchpad.lua, so the touchpad window
-- (Setup > Config > Mouse & Touchpad) can show and change them:
--   Three fingers left / right: previous / next workspace, empty ones included
--   Three fingers up / down: the AI console / the Omarchy menu
--   Four fingers left / right: take the active window to the neighbouring workspace
--   Four fingers down: fullscreen
--
-- Hyprland rejects a second gesture on the same fingers and direction, so
-- overriding one of these by hand means unsetting it first:
--   hl.gesture({ fingers = 3, direction = "up", action = "unset" })
-- Or turn them all off with omarchy_default_gestures = false in hyprland.lua.

require("default.hypr.touchpad").add_defaults()
