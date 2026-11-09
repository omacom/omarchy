-- Hyprland draws the boot splash over everything from its first frame, as
-- Plymouth last drew it: the splash's colour (looknfeel.lua), its logo and,
-- after a disk password, its progress bar carried on from where Plymouth's
-- stood. The shell's login cover asks it to fill the bar and fade out once the
-- desktop is ready. Only while Plymouth still holds its frame, so a config
-- reload later in the session never brings it back, and only on a Hyprland
-- that can draw it.
local plymouth = io.open("/run/plymouth/pid", "r")
if not plymouth or not o.splash_background() or not hl.get_config("misc.startup_splash_logo") then
  if plymouth then
    plymouth:close()
  end
  return
end
plymouth:close()

local theme = "/usr/share/plymouth/themes/omarchy/"

local function png_height(name)
  local file = io.open(theme .. name, "rb")
  if not file then
    return nil
  end
  local header = file:read(24)
  file:close()
  if not header or #header < 24 then
    return nil
  end
  return string.unpack(">I4", header, 21)
end

-- When the bar started, in CLOCK_MONOTONIC milliseconds, and the device scale
-- Plymouth drew at, as the handoff read them off Plymouth's last frame
-- (omarchy-plymouth-handoff). Without them, no bar, and Hyprland picks the
-- scale as Plymouth would.
local bar_start, scale = 0, 0
local recorded = io.open("/run/omarchy-boot-splash-bar", "r")
if recorded then
  local start, drawn = (recorded:read("*l") or ""):match("^(%d+)%s*(%d*)")
  bar_start, scale = tonumber(start or "") or 0, tonumber(drawn or "") or 0
  recorded:close()
end

local entry, box = png_height("entry.png"), png_height("progress_box.png")

hl.config({
  misc = {
    startup_splash_logo = theme .. "logo.png",
    startup_splash_bar = theme .. "progress_bar.png",
    startup_splash_bar_box = theme .. "progress_box.png",
    -- omarchy.script's layout(): the bar's box centred on the password field,
    -- which sits 40 px under the logo.
    startup_splash_bar_offset = entry and box and (40 + entry / 2 - box / 2) or 0,
    startup_splash_bar_start = bar_start,
    startup_splash_scale = scale,
  },
})

-- The shell's login cover then leaves the splash to Hyprland.
hl.env("OMARCHY_HYPRLAND_SPLASH", "1")

-- Hyprland zooms a monitor in as it is added, which would zoom the splash too.
hl.animation({ leaf = "monitorAdded", enabled = false })
