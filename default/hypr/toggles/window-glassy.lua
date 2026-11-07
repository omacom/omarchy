-- Frosted glass from the glassy Starship (#14726): whatever is behind a
-- see-through window or shell surface is blurred. Terminals get the see-through
-- background itself from omarchy-theme-set-glass, which keeps their text crisp.
require("default.hypr.glass")()

-- GTK apps fade as a whole, since GTK draws their backgrounds solid, and get
-- their blur from the backdrop-filter Glassy adds to the user's gtk.css.
o.window("org\\.gnome\\.Nautilus", { opacity = "0.75 0.75" })

hl.layer_rule({
  match = { namespace = "^(omarchy-bar|omarchy-menu|omarchy-notifications|omarchy-osd|omarchy-polkit|omarchy-reminders|omarchy-clipboard|omarchy-emojis|omarchy-image-selector|omarchy-keyboard-panel|omarchy-network-qr)$" },
  blur = true,
  ignore_alpha = 0.3,
})
