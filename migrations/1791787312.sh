echo "Share the selected region on monitors away from the top-left corner"

# The shipped region command gave slurp's layout coordinates, but the picker
# wants them relative to the chosen output. Only that exact line is changed.
config="$HOME/.config/hyprland-preview-share-picker/config.yaml"

# Dotfile managers may own the file or a parent directory through a symlink.
# Preserve that layout rather than detaching or editing its target.
path="$config"
while [[ $path != "$HOME" && $path != / ]]; do
  if [[ -L $path ]]; then
    echo "Preserving symlink-managed share picker config: $config"
    exit 0
  fi
  path=$(dirname "$path")
done

if [[ -f $config ]]; then
  sed -i "s/^  command: slurp -f '%o@%x,%y,%w,%h'\$/  command: slurp -f '%o@%X,%Y,%W,%H'/" "$config"
fi
