-- Android apps run through Waydroid in multi-window mode, each as its own
-- Wayland toplevel (app_id "waydroid.<package>"). Treat them like any native
-- Omarchy window: float on first open at a phone-ish size, centered, and fully
-- resizable from there. Harmless when Waydroid is not installed -- nothing
-- matches. See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
o.window({ class = "^(waydroid\\..*)$" }, {
  float = true,
  center = true,
  size = { 480, 880 },
  idle_inhibit = "fullscreen",
})

-- Waydroid's own background surface (shown briefly while the session comes up).
o.window({ class = "^(Waydroid)$" }, { float = true, center = true })
