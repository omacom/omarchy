-- Festival Loom — theme-only window treatment.
local activeBorderColor = { colors = { "rgb(AD285B)", "rgb(187D83)" }, angle = 45 }
local inactiveBorderColor = "rgba(796A708F)"
local shadowColor = "rgba(5546544D)"
local shellSurfaces = "^(omarchy-bar|omarchy-menu|omarchy-image-selector|omarchy-emojis|omarchy-clipboard|omarchy-keyboard-panel|omarchy-notifications|omarchy-osd|omarchy-polkit|omarchy-reminders|omarchy-network-qr|omarchy-network-speedtest|omarchy-disk-speedtest|omarchy-speed-test)$"
hl.config({
 general = { col = { active_border = activeBorderColor, inactive_border = inactiveBorderColor }, border_size = 4, gaps_in = 6, gaps_out = 13 },
 group = { col = { border_active = activeBorderColor, border_inactive = inactiveBorderColor, border_locked_active = "rgb(9B7300)", border_locked_inactive = inactiveBorderColor } },
 decoration = { rounding = 12, rounding_power = 3, active_opacity = 1.0, inactive_opacity = 1.0, blur = { enabled = true, size = 3, passes = 1, noise = 0.012, contrast = 0.98, brightness = 0.90, vibrancy = 0.05, vibrancy_darkness = 0.80, ignore_opacity = true }, shadow = { enabled = true, color = shadowColor, range = 12, render_power = 2 } },
})
hl.curve("FestivalLoomEase", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 3.5, bezier = "FestivalLoomEase" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.0, bezier = "FestivalLoomEase", style = "slidefade 14%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3.0, bezier = "FestivalLoomEase", style = "popin 92%" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.0, bezier = "FestivalLoomEase" })
hl.animation({ leaf = "border", enabled = true, speed = 3.0, bezier = "FestivalLoomEase" })
hl.animation({ leaf = "borderangle", enabled = false })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3.5, bezier = "FestivalLoomEase", style = "slidefade 12%" })
hl.layer_rule({ name = "festival-loom-shell-surface", match = { namespace = shellSurfaces }, blur = true, blur_popups = true, ignore_alpha = 0.18 })
