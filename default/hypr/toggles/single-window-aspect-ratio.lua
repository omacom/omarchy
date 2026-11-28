-- Avoid overly wide single-window layouts on wide screens.
hl.config({
  layout = {
    single_window_aspect_ratio = { 1, 1 },
  },

  scrolling = {
    fullscreen_on_one_column = false,
  },
})
