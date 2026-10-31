-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

o.window(".*", { suppress_event = "maximize" })

-- Fix some dragging issues with XWayland.
o.window(
  {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  { no_focus = true }
)

-- App-specific tweaks and terminal tags.
require("default.hypr.apps")

-- Terminals (including TUIs) and these desktop apps opt in to transparency.
o.transparent_window({ tag = "terminal" })
o.transparent_window("(omawrite|1[pP]assword|com\\.onepassword\\.OnePassword|org\\.gnome\\.Nautilus)")

-- The transparency hotkey opts otherwise opaque windows in with this tag.
o.transparent_window({ tag = "transparent" })
