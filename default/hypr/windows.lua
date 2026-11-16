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

-- Java AWT tooltips/menus are real X11 windows that reuse the parent class
-- and title themselves win0, win1, ... Float them so a floating workspace
-- leaves their size alone, and keep them unfocused.
o.window({
  title = "^win[0-9]+$",
  xwayland = true,
}, {
  float = true,
  no_initial_focus = true,
  no_focus = true,
  no_follow_mouse = true,
})

-- App-specific tweaks and terminal tags.
require("default.hypr.apps")

-- Terminals (including TUIs) and these desktop apps opt in to transparency.
o.transparent_window({ tag = "terminal" })
o.transparent_window("(omawrite|1[pP]assword|com\\.onepassword\\.OnePassword|org\\.gnome\\.Nautilus|folio)")

-- The transparency hotkey opts otherwise opaque windows in with this tag.
o.transparent_window({ tag = "transparent" })
