echo "Replace a desktop portal that started before the display existed"

# omarchy-settings ships the drop-in. A portal already running from earlier in
# this login still has the empty environment it started with, and daemon-reload
# alone does not replace it. Restart only once a display is in the manager, so
# an update over SSH does not stop the portal and then fail to bring it back.
systemctl --user daemon-reload >/dev/null 2>&1 || true

if systemctl --user is-active --quiet graphical-session.target \
  && systemctl --user show-environment | grep -q '^WAYLAND_DISPLAY='; then
  systemctl --user try-restart xdg-desktop-portal.service >/dev/null 2>&1 || true
fi
