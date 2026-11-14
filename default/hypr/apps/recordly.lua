-- Recordly's recording toolbar is a HUD: a transparent Electron surface with a small
-- opaque pill painted inside it. Two defaults work against that shape. The
-- default-opacity tag compounds with the app's own alpha until the desktop reads
-- through the controls, and the standard border is drawn around the whole transparent
-- surface, outlining a large empty rectangle around a small toolbar.
--
-- Matched on title rather than class alone: Recordly's editor is an ordinary window
-- that should tile and keep its border, and it shares the class with the toolbar.
o.window({ class = "^recordly$", title = "^Recordly$" }, {
  tag = "-default-opacity",
  float = true,
  -- The stop button has to stay reachable from whatever workspace you switch to while
  -- recording, and a toolbar that appears mid-sentence must not take the keystrokes.
  pin = true,
  no_initial_focus = true,
  no_dim = true,
  border_size = 0,
  no_shadow = true,
  opacity = "1 1",
})
