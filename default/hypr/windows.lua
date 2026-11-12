-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Hyprland tells every app it is maximized and takes any maximize request as a
-- toggle of its own maximize, so only apps that draw their own maximize button
-- are heard. Rules add their suppressed events up, so they are left out here.
o.window({ class = "negative:" .. o.self_framed_apps }, { suppress_event = "maximize" })

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
o.transparent_window("(omawrite|1[pP]assword|com\\.onepassword\\.OnePassword|org\\.gnome\\.Nautilus|folio)")

-- The transparency hotkey opts otherwise opaque windows in with this tag.
o.transparent_window({ tag = "transparent" })
