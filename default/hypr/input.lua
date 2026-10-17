-- https://wiki.hypr.land/Configuring/Basics/Variables/#input

local keyboard = require("default.hypr.keyboard")
local paths = require("default.hypr.paths")

-- Layouts that can't type Latin letters. Keep in sync with the list in
-- etc/mkinitcpio.conf.d/omarchy_hooks.conf.
local non_latin_layouts =
  " af am ara bd bg by et ge gr il in iq ir kg kh kz la lk mk mm mn mv np rs ru sy th tj ua "

local vconsole = keyboard.selected()

local kb_layout = vconsole.XKBLAYOUT or "us"
local kb_variant = vconsole.XKBVARIANT or ""
-- Caps Lock is Caps Lock, and Shift + Caps Lock is the compose key. Stock XKB
-- has no such option, so Omarchy defines it in /etc/xkb.
local kb_options = "omarchy:shift_caps_compose"

-- Hyprland resolves keybindings against the first entry in kb_layout, not the
-- layout that's currently active, so Omarchy's Latin-keysym bindings (SUPER + W
-- and friends) only fire when a Latin layout leads. Installing with a non-Latin
-- one would otherwise leave the desktop unusable.
if non_latin_layouts:find(" " .. kb_layout:match("^[^,]*") .. " ", 1, true) then
  kb_layout = "us," .. kb_layout
  kb_variant = "," .. kb_variant
  -- Reach the original layout with Left Alt + Right Alt.
  kb_options = kb_options .. ",grp:alts_toggle"
end

-- Saved selections already include their Latin-leading layout. Keep the
-- installer's layout-switching shortcut when a non-Latin layout remains.
if not kb_options:find("grp:alts_toggle", 1, true) then
  for layout in kb_layout:gmatch("[^,]+") do
    if non_latin_layouts:find(" " .. layout .. " ", 1, true) then
      kb_options = kb_options .. ",grp:alts_toggle"
      break
    end
  end
end

hl.config({
  input = {
    kb_layout = kb_layout,
    kb_variant = kb_variant,
    kb_model = "",
    kb_options = kb_options,
    kb_rules = "",
    follow_mouse = 1,
    sensitivity = 0,

    repeat_rate = 40,
    repeat_delay = 250,
    numlock_by_default = true,

    touchpad = {
      natural_scroll = false,
      clickfinger_behavior = true,
      scroll_factor = 0.4,
    },
  },

  misc = {
    key_press_enables_dpms = true,
    mouse_move_enables_dpms = true,
  },
})

-- Scroll nicely in the terminal.
o.window("(Alacritty|kitty)", { scroll_touchpad = 1.5 })
-- foot only applies its scrollback multiplier to wheel clicks, not precise touchpad scrolling.
o.window("foot", { scroll_touchpad = 2.0 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Chromebooks report each power key press from both the EC and the ACPI Power
-- Button, so toggle bindings like the power menu open and immediately close.
-- Ignore the ACPI duplicate only when the EC carries the key itself. Some
-- firmware exposes both ACPI power buttons (PNP0C0C and LNXPWRBN), which
-- Hyprland names power-button and power-button-1, so disable both.
if o.shell_succeeds(o.shell_quote(paths.omarchy_path .. "/bin/omarchy-hw-cros-ec-power-key")) then
  hl.device({ name = "power-button", enabled = false })
  hl.device({ name = "power-button-1", enabled = false })
end
