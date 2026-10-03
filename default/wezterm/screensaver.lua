-- The screensaver's terminal: a black canvas for omarchy-screensaver, nothing else.
-- Loaded with --config-file, so the user's own wezterm.lua never runs here -- a
-- screensaver must not inherit a theme, a tab bar, or a startup hook.

return {
  font_size = 18.0,

  -- ttfx measures the terminal once and paints to its edges; padding would
  -- leave a border of desktop-coloured nothing around a fullscreen window.
  window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
  enable_tab_bar = false,
  window_decorations = 'NONE',
  window_background_opacity = 1.0,

  colors = {
    background = '#000000',
    foreground = '#ffffff',
    -- omarchy-screensaver hides the mouse pointer; the text cursor has to go
    -- too, and the only way to hide it is to paint it the background colour.
    cursor_bg = '#000000',
    cursor_border = '#000000',
  },

  -- The effects already repaint the whole canvas at 120fps. A blinking cursor
  -- would schedule frames on top of that for something nobody can see.
  default_cursor_style = 'SteadyBlock',
  animation_fps = 1,

  audible_bell = 'Disabled',

  -- Dismissing the screensaver kills omarchy-screensaver and closes the window
  -- under a program that is still attached to the pty. Neither of those is an
  -- event to put a prompt in front of: there is nobody at the keyboard yet, and
  -- a confirmation dialog would be what the keypress actually woke them to.
  window_close_confirmation = 'NeverPrompt',
  exit_behavior = 'Close',
}
