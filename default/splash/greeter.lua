-- Minimal Hyprland config for the login screen (default/splash/greeter):
-- it runs the Quickshell greeter and exits once the greeter has handed greetd
-- the session to start, or has died, so greetd can start the session or a new
-- greeter.

hl.config({
  -- The layouts default/splash/layouts orders for the password (the greeter
  -- exports them), the one it starts in first, and no compose, Caps Lock or
  -- layout shortcut options: Splash.qml's keyboard button and Shift+Tab switch.
  input = {
    kb_layout = os.getenv("OMARCHY_SPLASH_XKBLAYOUT") or "us",
    kb_variant = os.getenv("OMARCHY_SPLASH_XKBVARIANT") or "",
    kb_options = "",
  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    background_color = "rgb(000000)",
    force_default_wallpaper = 0,
    -- default/splash/greeter runs Hyprland without start-hyprland on purpose.
    disable_watchdog_warning = true,
  },

  animations = {
    enabled = false,
  },

  -- No pointer, as at the boot splash, until it moves with the password field
  -- up, for the field's eye (ui/greeter.qml turns it on); it hides again once
  -- it rests or a key is typed.
  cursor = {
    invisible = true,
    inactive_timeout = 3,
    hide_on_key_press = true,
  },

  -- Hyprland's own update and donation screens would open over the login
  -- screen. The session turns them off in default/hypr/envs.lua, which this
  -- config never loads.
  ecosystem = {
    no_update_news = true,
    no_donation_nag = true,
  },
})

-- A monitor that took over the boot splash's last frame keeps it on screen
-- until the greeter's window (ui/Splash.qml) is opaque, as the desktop session
-- does for its startup cover (default/hypr/looknfeel.lua). A Hyprland without
-- the option, until Omarchy's lands, would show an error for it.
if hl.get_config("misc.startup_hold_layer") ~= nil then
  hl.config({ misc = { startup_hold_layer = "overlay:omarchy-splash" } })
end

hl.on("hyprland.start", function()
  hl.exec_cmd("quickshell --path /usr/share/omarchy/default/splash/ui/greeter.qml; hyprctl dispatch 'hl.dsp.exit()'")
end)
