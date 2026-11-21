echo "Add WezTerm terminal support"

# Match the defaults seeded for new users, including users who install the
# optional package later. Preserve existing files and alternate config locations.
if [[ ! -e ~/.config/wezterm/wezterm.lua && ! -L ~/.config/wezterm/wezterm.lua &&
  ! -e ~/.wezterm.lua && ! -L ~/.wezterm.lua && -z ${WEZTERM_CONFIG_FILE:-} &&
  ! -e ${XDG_CONFIG_HOME:-$HOME/.config}/wezterm/wezterm.lua && ! -L ${XDG_CONFIG_HOME:-$HOME/.config}/wezterm/wezterm.lua ]]; then
  mkdir -p ~/.config/wezterm
  cp "$OMARCHY_PATH/config/wezterm/wezterm.lua" ~/.config/wezterm/
fi

# The packaged WezTerm desktop entry carries no X-TerminalArg* keys, so
# xdg-terminal-exec cannot pass it a command, an app id, or a directory.
if [[ ! -e ~/.local/share/applications/org.wezfurlong.wezterm.desktop && ! -L ~/.local/share/applications/org.wezfurlong.wezterm.desktop ]]; then
  mkdir -p ~/.local/share/applications
  cp "$OMARCHY_PATH/applications/org.wezfurlong.wezterm.desktop" ~/.local/share/applications/
fi

# Existing themes predate the new template. Fill only its missing colors.
omarchy-theme-set-templates --file wezterm.lua "$HOME/.local/state/omarchy/current/theme"
