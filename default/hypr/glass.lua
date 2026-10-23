-- Frosted glass from the glassy Starship (#14726), shared by Glassy windows and
-- the Glassy bar: whatever is behind a see-through surface is blurred.
return function()
  hl.config({
    decoration = {
      blur = {
        enabled = true,
        size = 4,
        passes = 2,
        new_optimizations = true,
        xray = false,
        contrast = 1.0,
        brightness = 0.75,
        noise = 0.01,
        vibrancy = 0.35,
        vibrancy_darkness = 0.35,
        popups = true,
        special = true,
      },
    },
  })
end
