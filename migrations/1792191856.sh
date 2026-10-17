echo "Show the mouse pointer in browser screen shares"

# xdg-desktop-portal-hyprland advertises only hidden and embedded cursor modes,
# so Chromium's WebRTC portal client — which prefers metadata and sends no
# cursor_mode when that mode is not offered — started every share with the
# cursor hidden. The shipped xdph.conf now sets screencopy's cursor_mode to 2
# (embedded), the session default for clients that ask for no mode of their
# own; clients that do request a mode still get the one they asked for.

user_config="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/xdph.conf"

if [[ -f $user_config ]] && grep -q '^[[:space:]]*cursor_mode[[:space:]]*=' "$user_config"; then
  exit 0
fi

if [[ -f $user_config ]]; then
  # Keep whatever else the file carries: drop the setting into the existing
  # screencopy block when there is one, or append a block of its own (the
  # parser merges repeated blocks).
  if grep -q '^[[:space:]]*screencopy[[:space:]]*{' "$user_config"; then
    sed -i '/^[[:space:]]*screencopy[[:space:]]*{/a\
    cursor_mode = 2' "$user_config"
  else
    printf '\nscreencopy {\n    cursor_mode = 2\n}\n' >> "$user_config"
  fi
else
  install -Dm644 "$OMARCHY_PATH/config/hypr/xdph.conf" "$user_config"
fi

# xdph reads its config once at startup, and restarting it also drops the
# restore tokens that remember the old hidden-cursor sessions.
if systemctl --user is-active --quiet xdg-desktop-portal-hyprland.service 2>/dev/null; then
  if ! systemctl --user restart xdg-desktop-portal-hyprland.service; then
    echo "Failed to restart xdg-desktop-portal-hyprland" >&2
  fi
fi
