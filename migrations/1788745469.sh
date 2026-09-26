echo "Silence fcitx5 startup layout tip notifications"

# The unit used to only disable notificationitem (tray duplicate). The keyboard
# addon still fired freedesktop tips on layout/IM startup (issue #10474). The
# packaged unit now disables notifications as well; reload so an already-enabled
# user manager picks up the new ExecStart without waiting for the next login.

systemctl --user daemon-reload >/dev/null 2>&1 || true

if systemctl --user is-enabled --quiet omarchy-fcitx5.service 2>/dev/null &&
  systemctl --user is-active --quiet graphical-session.target 2>/dev/null; then
  # Restart only in a live graphical session so compose sequences come back
  # under the new flags; outside a session ConditionEnvironment would skip.
  systemctl --user restart omarchy-fcitx5.service >/dev/null 2>&1 || true
fi
