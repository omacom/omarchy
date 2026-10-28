-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Monitor scale is Hyprland's scale for the output. It sizes everything
-- Wayland-native, accepts fractions (1.6, 1.75), and applies immediately.
-- "auto" lets Hyprland pick per display.
local omarchy_monitor_scale = "auto"
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- GDK scale is GDK_SCALE, the factor GTK draws its own UI at. It's what
-- sizes X11/XWayland windows. GTK only honors whole numbers, so use the
-- nearest integer to the monitor scale, and restart an app for a change to
-- reach it.
local omarchy_gdk_scale = 2
hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- X11 apps draw at the GDK scale, so Hyprland lays X11 out at that scale too
-- and shows each X11 window at the size it would have on Wayland, on every
-- monitor. A Hyprland without xwayland:scale skips this and leaves X11
-- windows unscaled, as before.
if hl.get_config("xwayland.scale") ~= nil then
  hl.config({ xwayland = { scale = omarchy_gdk_scale } })
end
