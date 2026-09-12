echo "Stop the screensaver interrupting video playback"

# xdg-desktop-portal-gtk is the only installed backend offering org.freedesktop.impl.portal.Inhibit,
# and it forwards to org.gnome.SessionManager or org.freedesktop.ScreenSaver, neither of which exists
# under Omarchy, so every inhibit request fails. Firefox-based browsers commit to the portal whenever
# the interface is present and only fall back to the Wayland idle-inhibit protocol when it is absent,
# so a playing video never held off the screensaver. Ship the config that removes the interface.
portals_conf=~/.config/xdg-desktop-portal/hyprland-portals.conf

# Omarchy has never shipped this file, so anything already here is the user's own routing; leave it.
if [[ -f $portals_conf ]]; then
  echo "Keeping your existing $portals_conf; add 'org.freedesktop.impl.portal.Inhibit=none' under [preferred] to apply the fix."
else
  mkdir -p ~/.config/xdg-desktop-portal
  cp -f "$OMARCHY_PATH/config/xdg-desktop-portal/hyprland-portals.conf" "$portals_conf"
  systemctl --user try-restart xdg-desktop-portal.service
fi
