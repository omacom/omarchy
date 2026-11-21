-- The Glassy bar: the shell draws the bar see-through, and Hyprland blurs what
-- is behind it.
require("default.hypr.glass")()

-- The bar's layer spans the whole screen, so without xray Hyprland re-blurs the
-- windows under all of it whenever one redraws. xray blurs only the wallpaper,
-- which is all that sits behind the bar strip in tiling.
hl.layer_rule({
  match = { namespace = "^omarchy-bar$" },
  blur = true,
  ignore_alpha = 0.3,
  xray = true,
})
