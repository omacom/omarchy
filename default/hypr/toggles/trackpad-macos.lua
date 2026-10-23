-- macOS-style trackpad behavior, for switchers who want the gestures they
-- know: content follows the fingers when scrolling, and a three-finger swipe
-- left or right changes workspace the way it changes desktops on macOS.
--
-- Turn on with `omarchy toggle trackpad-macos`. Nothing here is enabled by
-- default; Omarchy's stock defaults stay untouched until you ask for it.
hl.config({
  input = {
    touchpad = {
      natural_scroll = true,
    },
  },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
