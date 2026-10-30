-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

o.window(".*", { suppress_event = "maximize" })

-- Hold off idle while any window is fullscreen (2), so games from any launcher
-- don't lock mid-play. Full width (maximized, 1) doesn't count. App rules below
-- still override it.
o.window({ fullscreen_state_internal = 2 }, { idle_inhibit = "fullscreen" })

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
