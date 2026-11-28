-- The native TTFX Plymouth splash hands its last frame to the desktop
-- (docs/plymouth-ttfx.md): omarchy-plymouth-handoff starts a continuity client
-- that shows it as an overlay layer until the desktop is ready.
local continuity = "omarchy-plymouth-continuity"

-- Above the shell's own startup cover (a lower order draws on top), and drawn
-- at once, with no fade in.
hl.layer_rule({ match = { namespace = "^" .. continuity .. "$" }, no_anim = true, animation = "none", order = -100 })

-- The monitorAdded animation zooms a display's first frames in over the boot
-- frame, displays plugged in later too.
hl.animation({ leaf = "monitorAdded", enabled = false })

-- With Omarchy's Hyprland: a display aquamarine adopted lit at startup
-- (AQ_SPLASH_ADOPT, default/uwsm/env.d/10-omarchy) keeps the boot frame until
-- the client's layer is opaque, and no cursor shows over it until a client
-- sets one or the pointer moves. An older Hyprland has neither option.
if hl.get_config("misc.startup_hold_layer") ~= nil then
  hl.config({ misc = { startup_hold_layer = "overlay:" .. continuity } })
end
if hl.get_config("cursor.hide_at_startup") ~= nil then
  hl.config({ cursor = { hide_at_startup = true } })
end
