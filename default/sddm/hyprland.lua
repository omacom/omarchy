-- Minimal Hyprland config for the SDDM Wayland greeter.
-- SDDM starts the greeter itself after the compositor is ready.
--
-- Keep this lean: no session shell, no autostart apps. The greeter still needs
-- the same lid / DPMS behaviour the user session gets from input.lua and the
-- lid binds in bindings/utilities.lua, otherwise a docked laptop that was left
-- lid-closed after Log Out never wakes its external monitor on input
-- (issue #10403).

hl.config({
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
    -- Match default/hypr/input.lua so a blanked external display comes back on
    -- mouse or keyboard without forcing the lid open/close cycle.
    key_press_enables_dpms = true,
    mouse_move_enables_dpms = true,
  },

  animations = {
    enabled = false,
  },
})

-- Reconcile internal vs external outputs the same way the session does. Call
-- clamshell directly (not omarchy-system-lid-close): the greeter must not try
-- to lock a session that does not exist.
local clamshell = hl.dsp.exec_cmd("omarchy-hyprland-monitor-clamshell")
hl.bind("switch:on:Lid Switch", clamshell, { locked = true })
hl.bind("switch:off:Lid Switch", clamshell, { locked = true })

-- Lid may already be closed when the greeter starts after Log Out.
hl.on("hyprland.start", function()
  hl.exec_cmd("omarchy-hyprland-monitor-clamshell")
end)
