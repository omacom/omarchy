-- The Glassy bar: the shell draws the bar and its popup cards see-through, and
-- Hyprland blurs what is behind them.
require("default.hypr.glass")()

hl.layer_rule({
  match = { namespace = "^omarchy-(bar|keyboard-panel)$" },
  blur = true,
  ignore_alpha = 0.3,
})
