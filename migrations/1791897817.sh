echo "Bring back herdr's sidebar dividers, which a black surface_dim hid"

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

# Only the surface_dim shipped right under panel_bg = "reset" goes; one of the
# user's own anywhere else is kept.
if [[ -f $config ]] && grep -qzP '(?m)^panel_bg = "reset"\nsurface_dim = "black"$' "$config"; then
  sed -i '/^panel_bg = "reset"$/{n;/^surface_dim = "black"$/d}' "$config"
  omarchy-restart-herdr || true
fi
