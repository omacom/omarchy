return {
  foreground = "{{ foreground }}",
  background = "{{ background }}",
  cursor_bg = "{{ bright_foreground }}",
  cursor_border = "{{ bright_foreground }}",
  cursor_fg = "{{ background }}",
  selection_fg = "{{ selection_foreground }}",
  selection_bg = "{{ selection_background }}",
  ansi = {
    "{{ background }}", "{{ red }}", "{{ green }}", "{{ yellow }}",
    "{{ blue }}", "{{ magenta }}", "{{ cyan }}", "{{ foreground }}",
  },
  brights = {
    "{{ muted }}", "{{ bright_red }}", "{{ bright_green }}", "{{ bright_yellow }}",
    "{{ bright_blue }}", "{{ bright_magenta }}", "{{ bright_cyan }}", "{{ bright_foreground }}",
  },
  tab_bar = {
    background = "{{ background }}",
    active_tab = {
      bg_color = "{{ accent }}",
      fg_color = "{{ background }}",
    },
    inactive_tab = {
      bg_color = "{{ background }}",
      fg_color = "{{ foreground }}",
    },
    inactive_tab_hover = {
      bg_color = "{{ lighter_background }}",
      fg_color = "{{ foreground }}",
    },
    new_tab = {
      bg_color = "{{ background }}",
      fg_color = "{{ foreground }}",
    },
    new_tab_hover = {
      bg_color = "{{ lighter_background }}",
      fg_color = "{{ foreground }}",
    },
  },
}
