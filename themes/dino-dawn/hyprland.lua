-- Dino Dawn — soft fern edges in NobleDoodle's golden jungle.
-- Theme visuals only; layouts, bindings and window/app opacity remain user-owned.
local active_border = { colors = { "rgb(83CDB1)", "rgb(ACD77B)" }, angle = 90 }
local inactive_border = "rgba(AAC5B480)"

hl.config({
  general = {
    col = { active_border = active_border, inactive_border = inactive_border },
    border_size = 3,
    gaps_in = 7,
    gaps_out = 14,
  },
  group = {
    col = {
      border_active = active_border,
      border_inactive = inactive_border,
      border_locked_active = "rgb(F2D18E)",
      border_locked_inactive = inactive_border,
    },
  },
  decoration = {
    rounding = 16,
    rounding_power = 3,
    -- Mist, not frosted glass: soften foliage only where an app is transparent.
    -- No opacity overrides, grain, saturation boost, or shell layer rules.
    blur = {
      enabled = true,
      size = 3,
      passes = 2,
      noise = 0.0,
      contrast = 0.90,
      brightness = 0.96,
      vibrancy = 0.0,
    },
    shadow = {
      enabled = true,
      color = "rgba(14100E88)",
      range = 14,
      render_power = 3,
    },
  },
})

-- Retain the approved exit curve and timing unchanged.
-- Do not enable animations globally or change workspace/move/resize behavior.
hl.curve("dinoDawnUnfurl", {
  type = "bezier",
  points = { { 0.16, 1 }, { 0.3, 1 } },
})
-- Emerge through the mist at full size: no text scaling or last-moment settling.
-- Coordinate entry and fade; this does not change the app's steady-state opacity.
hl.curve("dinoDawnReveal", {
  type = "bezier",
  points = { { 0.2, 0 }, { 0.2, 1 } },
})
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2.4, bezier = "dinoDawnReveal", style = "popin 100%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2.4, bezier = "dinoDawnReveal" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "dinoDawnUnfurl", style = "popin 98%" })
-- Sunlight stays still: no perpetual gradient rotation.
hl.animation({ leaf = "borderangle", enabled = false })
