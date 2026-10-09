echo "Add WezTerm terminal support"

# Only a repair for installs that already run WezTerm. Anyone installing it from
# here on gets both files from omarchy-install-terminal.
if omarchy-cmd-missing wezterm; then
  exit 0
fi

if [[ ! -e ~/.config/wezterm/wezterm.lua ]]; then
  mkdir -p ~/.config/wezterm
  cp "$OMARCHY_PATH/config/wezterm/wezterm.lua" ~/.config/wezterm/
fi

# The packaged WezTerm desktop entry carries no X-TerminalArg* keys, so
# xdg-terminal-exec cannot pass it a command, an app id, or a directory.
if [[ ! -f ~/.local/share/applications/org.wezfurlong.wezterm.desktop ]]; then
  mkdir -p ~/.local/share/applications
  cp "$OMARCHY_PATH/applications/org.wezfurlong.wezterm.desktop" ~/.local/share/applications/
fi
