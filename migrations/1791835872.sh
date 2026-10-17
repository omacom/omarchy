echo "Pause video wallpapers on battery"

# owe reads only its config.toml under the XDG config home and keeps a video
# wallpaper playing on battery without one. A file that already exists, or a
# symlink even to nothing yet, is the user's own choice.
owe_config="${XDG_CONFIG_HOME:-$HOME/.config}/owe/config.toml"

if [[ ! -e $owe_config && ! -L $owe_config ]]; then
  install -Dm644 "$OMARCHY_PATH/config/owe/config.toml" "$owe_config"
  owe reload-config >/dev/null 2>&1 || true
fi
