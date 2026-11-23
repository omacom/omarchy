-- https://wiki.hypr.land/Configuring/Basics/Variables/#input

local keyboard = require("default.hypr.keyboard")

local kb_layout, kb_variant = keyboard.layouts()
-- Caps Lock is Caps Lock, and Shift + Caps Lock is the compose key. Stock XKB
-- has no such option, so Omarchy defines it in /etc/xkb.
local kb_options = "omarchy:shift_caps_compose"

-- Reach a non-Latin layout with Left Alt + Right Alt.
for layout in kb_layout:gmatch("[^,]+") do
  if keyboard.non_latin(layout) then
    kb_options = kb_options .. ",grp:alts_toggle"
    break
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

-- Scroll nicely in the terminal. TUIs launched under their own app-id
-- (org.omarchy.agent in the console, org.omarchy.btop, TUI.float, ...) no longer
-- carry the terminal's class, but their initial title is still the terminal's
-- name, so they are matched by that to scroll at the same rate.
local function terminal_scroll(class, title, factor)
  o.window(class, { scroll_touchpad = factor })
  o.window({ class = "(org\\.omarchy\\..*|TUI\\..*)", initial_title = title }, { scroll_touchpad = factor })
end

terminal_scroll("(Alacritty|kitty)", "(Alacritty|kitty)", 1.5)
-- foot only applies its scrollback multiplier to wheel clicks, not precise touchpad scrolling.
terminal_scroll("foot", "foot", 2.0)
terminal_scroll("com.mitchellh.ghostty", "Ghostty", 0.2)
