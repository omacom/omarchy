echo "Stop fcitx5 from pushing keyboard layouts to the Wayland compositor"

wayland_conf="$HOME/.config/fcitx5/conf/wayland.conf"

if [[ ! -e $wayland_conf ]]; then
  mkdir -p "$(dirname "$wayland_conf")"
  cp "$OMARCHY_PATH/config/fcitx5/conf/wayland.conf" "$wayland_conf"
fi
