return {
  foreground = "{{ foreground }}",
  background = "{{ background }}",
  cursor_bg = "{{ bright_foreground }}",
  cursor_fg = "{{ background }}",
  cursor_border = "{{ bright_foreground }}",
  selection_fg = "{{ selection_foreground }}",
  selection_bg = "{{ selection_background }}",

  ansi = {
    "{{ background }}",
    "{{ red }}",
    "{{ green }}",
    "{{ yellow }}",
    "{{ blue }}",
    "{{ magenta }}",
    "{{ cyan }}",
    "{{ foreground }}",
  },

  brights = {
    "{{ muted }}",
    "{{ bright_red }}",
    "{{ bright_green }}",
    "{{ bright_yellow }}",
    "{{ bright_blue }}",
    "{{ bright_magenta }}",
    "{{ bright_cyan }}",
    "{{ bright_foreground }}",
  },
}
