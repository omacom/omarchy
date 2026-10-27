echo "Disable portal idle inhibition to allow native Wayland idle inhibitor in Firefox"

portal_dir="${XDG_CONFIG_HOME:-$HOME/.config}/xdg-desktop-portal"
portal_config="$portal_dir/hyprland-portals.conf"

if [[ -f $portal_config ]]; then
  if ! grep -q '^org.freedesktop.impl.portal.Inhibit=' "$portal_config"; then
    echo "org.freedesktop.impl.portal.Inhibit=none" >> "$portal_config"
  fi
else
  install -Dm644 "$OMARCHY_PATH/config/xdg-desktop-portal/hyprland-portals.conf" "$portal_config"
fi

if systemctl --user is-active --quiet xdg-desktop-portal.service 2>/dev/null; then
  systemctl --user restart xdg-desktop-portal.service || true
fi
