-- Frosted glass from the glassy Starship (#14726): whatever is behind a
-- see-through window or shell surface is blurred. Terminals get the see-through
-- background itself from omarchy-theme-set-glass, which keeps their text crisp.
require("default.hypr.glass")()

-- Every other window opted in to transparency fades as a whole, since these
-- apps draw their backgrounds solid. GTK apps, such as Nautilus, get their blur
-- from the backdrop-filter Glassy adds to the user's gtk.css.
o.window({ tag = "transparent-window" }, { opacity = "0.75 0.75" })

-- Terminals keep the standard opacity: their glass is the see-through
-- background, and fading the whole window would fade their text with it.
o.window({ tag = "terminal" }, { opacity = "0.985 0.96" })

hl.layer_rule({
  match = { namespace = "^(omarchy-bar|omarchy-menu|omarchy-notifications|omarchy-osd|omarchy-polkit|omarchy-reminders|omarchy-clipboard|omarchy-emojis|omarchy-image-selector|omarchy-keyboard-panel|omarchy-network-qr)$" },
  blur = true,
  ignore_alpha = 0.3,
})
