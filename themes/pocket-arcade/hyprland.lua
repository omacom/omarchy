-- Pocket Arcade — candy-shell windows and playful arcade motion.
-- Theme-only visuals: no keybindings, layout changes, or app rules.
-- Respect the user's global animations toggle; do not force it on.
local activeBorderColor = { colors = { "rgb(F16F8B)", "rgb(EFD17C)", "rgb(79D0CC)" }, angle = 45 }
local inactiveBorderColor = "rgba(74758F8F)"
local shadowColor = "rgba(03050BDD)"
local shellSurfaces = "^(omarchy-bar|omarchy-menu|omarchy-image-selector|omarchy-emojis|omarchy-clipboard|omarchy-keyboard-panel|omarchy-notifications|omarchy-osd|omarchy-polkit|omarchy-reminders|omarchy-network-qr|omarchy-network-speedtest|omarchy-disk-speedtest|omarchy-speed-test)$"

hl.config({
  general = {
    col = { active_border = activeBorderColor, inactive_border = inactiveBorderColor },
    border_size = 4,
    gaps_in = 7,
    gaps_out = 14,
  },
  group = {
    col = {
      border_active = activeBorderColor,
      border_inactive = inactiveBorderColor,
      border_locked_active = "rgb(DAB968)",
      border_locked_inactive = inactiveBorderColor,
    },
  },
  decoration = {
    rounding = 20,
    rounding_power = 3,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      noise = 0.018,
      contrast = 0.97,
      brightness = 0.84,
      vibrancy = 0.06,
      vibrancy_darkness = 0.80,
      ignore_opacity = true,
    },
    shadow = { enabled = true, color = shadowColor, range = 22, render_power = 3 },
  },
})

-- A single soft overshoot on entry, like pressing a rubber arcade button.
-- Movement/resizing stays smooth rather than bouncing on every adjustment.
hl.curve("pocketArcadePop", {
  type = "bezier",
  points = { { 0.22, 1.18 }, { 0.36, 1 } },
})
hl.curve("pocketArcadeEase", {
  type = "bezier",
  points = { { 0.16, 1 }, { 0.3, 1 } },
})
hl.curve("pocketArcadeExit", {
  type = "bezier",
  points = { { 0.4, 0 }, { 1, 1 } },
})
hl.animation({ leaf = "windows", enabled = true, speed = 3.5, bezier = "pocketArcadeEase" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.5, bezier = "pocketArcadePop", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.5, bezier = "pocketArcadeExit", style = "popin 85%" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.5, bezier = "pocketArcadeEase" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2, bezier = "pocketArcadeEase" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2.5, bezier = "pocketArcadeExit" })
hl.animation({ leaf = "border", enabled = true, speed = 3, bezier = "pocketArcadeEase" })
-- Candy stripes stay still: no perpetual animation or flashing.
hl.animation({ leaf = "borderangle", enabled = false })
-- Short level-to-level slides rather than a full-screen sweep.
hl.animation({ leaf = "workspaces", enabled = true, speed = 3.5, bezier = "pocketArcadeEase", style = "slidefade 15%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3.5, bezier = "pocketArcadeEase", style = "slidefadevert 15%" })

hl.layer_rule({
  name = "pocket-arcade-shell-plastic",
  match = { namespace = shellSurfaces },
  blur = true,
  blur_popups = true,
  ignore_alpha = 0.18,
})
