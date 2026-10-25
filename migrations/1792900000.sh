echo "Repair unescaped multiline secret corruption in GNOME Keyring"

# Fixes corruption caused by clients storing multiline secrets (such as Proton VPN
# SSO or Flutter apps) without proper escaping, which causes gnome-keyring to drop
# the default cleartext keyring on boot.

# Coordinate with running daemon: mask and stop to prevent concurrent client writes
# or socket-activation races during the file repair window.
daemon_was_active=0
if systemctl --user is-active --quiet gnome-keyring-daemon.service 2>/dev/null; then
  daemon_was_active=1
fi

systemctl --user mask gnome-keyring-daemon.service gnome-keyring-daemon.socket >/dev/null 2>&1 || true
systemctl --user stop gnome-keyring-daemon.service gnome-keyring-daemon.socket >/dev/null 2>&1 || true

if command -v omarchy-keyring-repair >/dev/null 2>&1; then
  omarchy-keyring-repair || true
elif [[ -x $OMARCHY_PATH/bin/omarchy-keyring-repair ]]; then
  "$OMARCHY_PATH/bin/omarchy-keyring-repair" || true
fi

systemctl --user unmask gnome-keyring-daemon.service gnome-keyring-daemon.socket >/dev/null 2>&1 || true

# Restore daemon to pick up the normalized keyfile into memory
if (( daemon_was_active == 1 )); then
  systemctl --user start gnome-keyring-daemon.socket gnome-keyring-daemon.service >/dev/null 2>&1 || true
fi

# Ensure dbus-broker reloads service definitions if running
if systemctl --user is-active --quiet dbus-broker.service 2>/dev/null; then
  systemctl --user reload dbus-broker.service || true
fi
