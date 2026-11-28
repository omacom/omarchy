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

-- Swipe back to dismiss the menu or console.
local function menuOpen()
  for _, layer in ipairs(hl.get_layers({ namespace = "omarchy-menu" })) do
    if layer.mapped then return true end
  end
  return false
end

local function quakeOpen()
  local panel = hl.get_active_special_workspace()
  return panel and panel.name == "special:qconsole"
end

hl.gesture({ fingers = 3, direction = "up", action = function()
  if menuOpen() then return end
  if quakeOpen() then
    hl.dispatch(hl.dsp.workspace.toggle_special("qconsole"))
  else
    hl.dispatch(hl.dsp.global("omarchy:menu.root"))
  end
end })
hl.gesture({ fingers = 3, direction = "down", action = function()
  if menuOpen() then
    hl.exec_cmd("omarchy menu close")
  elseif not quakeOpen() then
    hl.dispatch(hl.dsp.workspace.toggle_special("qconsole"))
  end
end })

-- Four fingers take the active window along to the neighbouring workspace.
hl.gesture({ fingers = 4, direction = "left", action = function() hl.dispatch(hl.dsp.window.move({ workspace = "r-1" })) end })
hl.gesture({ fingers = 4, direction = "right", action = function() hl.dispatch(hl.dsp.window.move({ workspace = "r+1" })) end })
hl.gesture({ fingers = 4, direction = "down", action = "fullscreen" })
