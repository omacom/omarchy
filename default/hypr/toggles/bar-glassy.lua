-- The Glassy bar: the shell draws the bar see-through, and Hyprland blurs what
-- is behind it.
require("default.hypr.glass")()

hl.layer_rule({
  match = { namespace = "^omarchy-bar$" },
  blur = true,
  ignore_alpha = 0.3,
})
