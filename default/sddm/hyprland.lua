-- Minimal Hyprland config for the SDDM Wayland greeter.
-- SDDM starts the greeter itself after the compositor is ready.

-- SDDM launches this config with an explicit --config, so nothing in
-- default/hypr is loaded and Hyprland would fall back to its built-in "us"
-- layout. The greeter is the only place a password is typed by hand, so a
-- non-US layout there rejects correct passwords. dofile keeps this independent
-- of package.path and $HOME, neither of which the greeter's environment sets.
local keyboard = dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/keyboard.lua")

hl.config({
  input = {
    kb_layout = keyboard.layout,
    kb_variant = keyboard.variant,
    kb_options = keyboard.options,
    numlock_by_default = true,
  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
  },

  animations = {
    enabled = false,
  },
})
