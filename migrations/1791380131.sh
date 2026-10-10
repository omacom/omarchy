echo "Install the folder-color Nautilus extension for existing users"

source="$OMARCHY_PATH/default/nautilus-python/extensions/omarchy_folder_color.py"
target_dir="$HOME/.local/share/nautilus-python/extensions"

if [[ -f $source ]]; then
  mkdir -p "$target_dir"
  cp "$source" "$target_dir/"
fi
