-- A lone modifier press wakes from the screensaver, as on other desktops.
-- The screensaver only exits when a character reaches its terminal, so Shift,
-- Ctrl, Alt and Super did nothing, and the character keys that do work get
-- typed into whatever window takes focus next. Modifiers never produce a
-- character, which makes them the wake keys that cannot leak.
-- The binds are non-consuming and look for a screensaver window first, so an
-- ordinary modifier press costs one window lookup and still reaches the app.
local function dismiss_screensaver()
  for _, window in ipairs(hl.get_windows({ class = "org.omarchy.screensaver" })) do
    hl.dispatch(hl.dsp.window.close(window))
  end
end

for _, key in ipairs({
  "SHIFT + SHIFT_L", "SHIFT + SHIFT_R",
  "CTRL + CONTROL_L", "CTRL + CONTROL_R",
  "ALT + ALT_L", "ALT + ALT_R",
  "SUPER + SUPER_L", "SUPER + SUPER_R",
}) do
  hl.bind(key, dismiss_screensaver, { non_consuming = true })
end
