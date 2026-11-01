-- Omarchy's monitor defaults: every monitor at its preferred mode, placed
-- automatically, at the scale Hyprland picks for it. The display panel's
-- choices for a monitor (default/hypr/monitor-settings.lua) and anything in
-- hypr/monitors.lua load after these and win.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-- GDK_SCALE is the factor GTK draws its own UI at, which sizes X11/XWayland
-- windows: Omarchy leaves those unscaled by the compositor so they stay crisp.
-- Start at 2 until monitors are available. monitor-settings.lua then follows
-- the lowest connected monitor scale, even before a panel choice is saved.
hl.env("GDK_SCALE", "2")
