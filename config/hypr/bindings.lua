-- Keep only your personal keybinding overrides here. Add new bindings with
-- o.bind, which also replaces defaults for the same press/release event.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding without unbinding it first.
-- This example replaces the default file manager with Flea.
-- o.bind("SUPER + SHIFT + F", "File manager", { launch = "flea" })

-- Use o.rebind to replace every event on a key, including press and release.
-- To deliberately stack actions on the same event, pass { append = true }.

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, { panel = "omarchy.emojis" })
