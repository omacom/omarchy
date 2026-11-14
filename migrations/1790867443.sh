echo "Render GTK3 with GLES on NVIDIA so Sushi can play video previews"

if omarchy-hw-nvidia; then
  # Hyprland imports its env into systemd and D-Bus only at login, so D-Bus-activated Sushi keeps desktop GL until
  # the next one; a GDK_GL already imported there came from the user's own Hyprland config, so leave it be.
  if ! grep -q '^GDK_GL=' <<<"$(systemctl --user show-environment 2>/dev/null)"; then
    dbus-update-activation-environment --systemd GDK_GL=gles || omarchy-state set reboot-required
  fi
fi
