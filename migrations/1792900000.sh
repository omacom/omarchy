echo "Repair unescaped multiline secret corruption in GNOME Keyring"

# Fixes corruption caused by clients storing multiline secrets (such as Proton VPN
# SSO or Flutter apps) without proper escaping, which causes gnome-keyring to drop
# the default cleartext keyring on boot.

service="gnome-keyring-daemon.service"
socket="gnome-keyring-daemon.socket"

# Record active state and existing masks before taking action
service_was_active=0
if systemctl --user is-active --quiet "$service" 2>/dev/null; then
  service_was_active=1
fi

masked_service=0
if [[ $(systemctl --user is-enabled "$service" 2>/dev/null) != masked* ]]; then
  if systemctl --user mask --runtime "$service" >/dev/null 2>&1; then
    masked_service=1
  fi
fi

masked_socket=0
if [[ $(systemctl --user is-enabled "$socket" 2>/dev/null) != masked* ]]; then
  if systemctl --user mask --runtime "$socket" >/dev/null 2>&1; then
    masked_socket=1
  fi
fi

cleanup() {
  # Remove only temporary runtime masks created by this migration
  if (( masked_service == 1 )); then
    systemctl --user unmask --runtime "$service" >/dev/null 2>&1 || true
    rm -f "${XDG_RUNTIME_DIR:-/run/user/$UID}/systemd/user/$service" 2>/dev/null || true
  fi
  if (( masked_socket == 1 )); then
    systemctl --user unmask --runtime "$socket" >/dev/null 2>&1 || true
    rm -f "${XDG_RUNTIME_DIR:-/run/user/$UID}/systemd/user/$socket" 2>/dev/null || true
  fi

  systemctl --user daemon-reload >/dev/null 2>&1 || true

  # Restore daemon if it was active and not persistently masked
  if (( service_was_active == 1 && masked_service == 1 )); then
    systemctl --user start "$socket" "$service" >/dev/null 2>&1 || true
  fi
}

# Signal handlers exit immediately, allowing the EXIT trap to restore units once
trap 'exit 1' INT TERM
trap cleanup EXIT

if systemctl --user is-active --quiet "$service" 2>/dev/null; then
  systemctl --user stop "$service" "$socket" >/dev/null 2>&1 || true
fi

# Run the offline repair
if command -v omarchy-keyring-repair >/dev/null 2>&1; then
  omarchy-keyring-repair || true
elif [[ -x $OMARCHY_PATH/bin/omarchy-keyring-repair ]]; then
  "$OMARCHY_PATH/bin/omarchy-keyring-repair" || true
fi

# Ensure dbus-broker reloads service definitions if running
if systemctl --user is-active --quiet dbus-broker.service 2>/dev/null; then
  systemctl --user reload dbus-broker.service >/dev/null 2>&1 || true
fi
