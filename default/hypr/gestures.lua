-- Touchpad gestures. See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
--
-- Hyprland rejects a second gesture on the same fingers and direction, so
-- overriding one of these means unsetting it first:
--   hl.gesture({ fingers = 3, direction = "up", action = "unset" })
-- Or turn them all off with omarchy_default_gestures = false in hyprland.lua.

-- Swipe through workspaces, empty ones included. Workspace switches aren't
-- animated, so the switch lands when the swipe ends rather than dragging the
-- workspace along under the fingers.
hl.gesture({ fingers = 3, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ workspace = "r-1" })) end })
hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ workspace = "r+1" })) end })

-- Push up for the AI console, and pull down for the Omarchy menu.
hl.gesture({ fingers = 3, direction = "up", action = "special", workspace_name = "qconsole" })
hl.gesture({ fingers = 3, direction = "down", action = function() hl.dispatch(hl.dsp.global("omarchy:menu.root")) end })

-- Four fingers take the active window along to the neighbouring workspace.
hl.gesture({ fingers = 4, direction = "left", action = function() hl.dispatch(hl.dsp.window.move({ workspace = "r-1" })) end })
hl.gesture({ fingers = 4, direction = "right", action = function() hl.dispatch(hl.dsp.window.move({ workspace = "r+1" })) end })
hl.gesture({ fingers = 4, direction = "down", action = "fullscreen" })
