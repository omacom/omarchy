echo "Free Super+Space from fcitx5 so the Omarchy menu opens"

# fcitx5's compiled default binds Super+Space to switching input-method
# groups, and Super+Shift+Space to switching back. Omarchy starts fcitx5 in
# every session so ~/.XCompose works, and those defaults consume the menu
# key and the top-bar toggle before Hyprland sees them. The shipped config
# clears both hotkeys. A config the user already wrote is left alone.

shipped="$OMARCHY_PATH/config/fcitx5/config"
config="$HOME/.config/fcitx5/config"

if [[ ! -f $shipped ]]; then
  echo "Shipped fcitx5 config is missing: $shipped"
  exit 1
fi

if [[ -e $config ]] && ! cmp -s "$shipped" "$config"; then
  exit 0
fi

if [[ ! -e $config ]]; then
  mkdir -p "$(dirname "$config")"
  cp "$shipped" "$config"
fi

# The running process keeps the old hotkeys until it reloads. With no
# graphical session there is nothing to reload; the next start reads the file.
if systemctl --user is-active --quiet omarchy-fcitx5.service; then
  gdbus call --session \
    --dest org.fcitx.Fcitx5 \
    --object-path /controller \
    --method org.fcitx.Fcitx.Controller1.ReloadConfig \
    >/dev/null
fi
