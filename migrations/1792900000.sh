echo "Repair unescaped multiline secret corruption in GNOME Keyring"

# Fixes corruption caused by clients storing multiline secrets (such as Proton VPN
# SSO or Flutter apps) without proper escaping, which causes gnome-keyring to drop
# the default cleartext keyring on boot.
if command -v omarchy-keyring-repair >/dev/null 2>&1; then
  omarchy-keyring-repair || true
elif [[ -x $OMARCHY_PATH/bin/omarchy-keyring-repair ]]; then
  "$OMARCHY_PATH/bin/omarchy-keyring-repair" || true
fi

# Ensure dbus-broker reloads service definitions if running
if systemctl --user is-active --quiet dbus-broker.service 2>/dev/null; then
  systemctl --user reload dbus-broker.service || true
fi
