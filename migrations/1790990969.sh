echo "Let theme changes clear the tmux colours stamped before this update"

# omarchy-theme-set-tmux now only unsets a window style matching its own
# record, and the script before it stamped the current theme without one.
colors="$HOME/.local/state/omarchy/current/theme/colors.toml"

if [[ -f $colors ]] && tmux list-sessions >/dev/null 2>&1; then
  stamp="fg=$(omarchy-theme-color --file "$colors" foreground),bg=$(omarchy-theme-color --file "$colors" background)"

  for style in window-style window-active-style; do
    if [[ $(tmux show-option -gv "$style" 2>/dev/null) == "$stamp" ]]; then
      tmux set-option -g "@omarchy_${style//-/_}" "$stamp"
    fi
  done
fi
