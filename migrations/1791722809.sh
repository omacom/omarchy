echo "Let herdr's tab bar show the terminal's background, so it turns glassy too"

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

# Only a tab bar still on the shipped black changes; any other choice is kept,
# and a surface_dim of the user's own is never given a second one.
if [[ -f $config ]] && grep -qx 'panel_bg = "black"' "$config" && ! grep -q '^[[:space:]]*surface_dim[[:space:]]*=' "$config"; then
  sed -i 's/^panel_bg = "black"$/panel_bg = "reset"\nsurface_dim = "black"/' "$config"
  omarchy-restart-herdr || true
fi
