-- The Glassy bar: the shell draws the bar see-through, and Hyprland blurs what
-- is behind it.
require("default.hypr.glass")()

hl.layer_rule({
  match = { namespace = "^omarchy-bar$" },
  blur = true,
  ignore_alpha = 0.3,
  -- The bar's layer spans the whole monitor, so a live blur behind it is redone
  -- on every damaged frame anywhere on screen. xray blurs it from the cached
  -- wallpaper blur instead.
  xray = true,
})
