-- The Glassy dock: the shell draws the box behind the dock's apps see-through,
-- and Hyprland blurs what is behind it.
require("default.hypr.glass")()

hl.layer_rule({
  match = { namespace = "^omarchy-dock$" },
  blur = true,
  ignore_alpha = 0.3,
})
