echo "Disable portal idle inhibition to allow native Wayland idle inhibitor in Firefox"

portal_dir="${XDG_CONFIG_HOME:-$HOME/.config}/xdg-desktop-portal"
portal_config="$portal_dir/hyprland-portals.conf"
generic_config="$portal_dir/portals.conf"

target=""
if [[ -f $portal_config ]]; then
  target="$portal_config"
elif [[ -f $generic_config ]]; then
  target="$generic_config"
fi

if [[ -n $target ]]; then
  if ! grep -q '^org.freedesktop.impl.portal.Inhibit=' "$target"; then
    [[ -n $(tail -c1 "$target") ]] && echo >> "$target"
    echo "org.freedesktop.impl.portal.Inhibit=none" >> "$target"
  fi
else
  install -Dm644 "$OMARCHY_PATH/config/xdg-desktop-portal/hyprland-portals.conf" "$portal_config"
fi

if systemctl --user is-active --quiet xdg-desktop-portal.service 2>/dev/null; then
  systemctl --user restart xdg-desktop-portal.service
fi
