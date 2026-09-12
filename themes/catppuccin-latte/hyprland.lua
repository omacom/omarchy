-- Quiet borders and square corners; opacity changes reset on theme switch.
hl.config({
  general = { col = { active_border = "#7883c3", inactive_border = "#ccd0da" } },
  decoration = { rounding = 0 },
  group = {
    col = { border_active = "#7883c3", border_inactive = "#ccd0da" },
    groupbar = {
      text_color = "#4c4f69", text_color_inactive = "#595c74",
      col = { active = "#e3e2ee", inactive = "#eeebed" },
      gradients = false, gradient_rounding = 0,
    },
  },
})

-- Keep Omarchy's media/application opacity opt-outs; don't stack opacity.
o.window({ tag = "default-opacity" }, { opacity = "1.0 0.96" })
o.window({ tag = "chromium-based-browser" }, { opacity = "1.0 0.96" })
o.window({ tag = "firefox-based-browser" }, { opacity = "1.0 0.96" })
