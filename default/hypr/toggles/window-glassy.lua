-- Frosted glass from the glassy Starship (#14726): whatever is behind a
-- see-through window or shell surface is blurred. omarchy-theme-set-glass has
-- the terminals and GTK apps that must ask for that blur do so.
require("default.hypr.glass")()

-- Every window fades as a whole, since most apps draw their backgrounds solid.
-- GTK apps, such as Nautilus, get their blur from the backdrop-filter Glassy
-- adds to the user's gtk.css. Floating workspaces leave their opacity to this.
o.window(".*", { opacity = "0.75 0.75" })

hl.layer_rule({
  match = { namespace = "^(omarchy-bar|omarchy-menu|omarchy-notifications|omarchy-osd|omarchy-polkit|omarchy-reminders|omarchy-clipboard|omarchy-emojis|omarchy-image-selector|omarchy-keyboard-panel|omarchy-network-qr)$" },
  blur = true,
  ignore_alpha = 0.3,
})
