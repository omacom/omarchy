echo "Dim herdr's unfocused pane borders, so the focused pane stands out"

config="$HOME/.config/herdr/config.toml"

# Dotfile managers may own the file or a parent directory through a symlink.
# Preserve that layout rather than detaching or editing its target.
path="$config"
while [[ $path != "$HOME" && $path != / ]]; do
  if [[ -L $path ]]; then
    echo "Preserving symlink-managed herdr config: $config"
    exit 0
  fi
  path=$(dirname "$path")
done

# Only a config still on the shipped terminal theme gets the line: another theme
# brings its own overlay0, and an overlay0 of the user's own is kept.
if [[ -f $config ]] && grep -qx 'name = "terminal"' "$config" && grep -qx '\[theme\.custom\]' "$config" &&
  ! grep -q '^[[:space:]]*overlay0[[:space:]]*=' "$config"; then
  sed -i 's/^\[theme\.custom\]$/[theme.custom]\noverlay0 = "darkgray"/' "$config"
  omarchy-restart-herdr || true
fi
