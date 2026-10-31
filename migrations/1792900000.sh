echo "Repair unescaped multiline secret corruption in GNOME Keyring"

# Fixes corruption caused by clients storing multiline secrets (such as Proton VPN
# SSO or Flutter apps) without proper escaping, which causes gnome-keyring to drop
# the default cleartext keyring on boot.

service="gnome-keyring-daemon.service"
socket="gnome-keyring-daemon.socket"

service_was_active=0
if systemctl --user is-active --quiet "$service" 2>/dev/null; then
  service_was_active=1
fi

socket_was_active=0
if systemctl --user is-active --quiet "$socket" 2>/dev/null; then
  socket_was_active=1
fi

# Track units masked by this migration to avoid unmasking user-masked units
masked_units=()
for unit in "$service" "$socket"; do
  if [[ $(systemctl --user is-enabled "$unit" 2>/dev/null) != masked* ]]; then
    if systemctl --user mask --runtime "$unit" >/dev/null 2>&1; then
      masked_units+=("$unit")
    fi
  fi
done

cleanup() {
  for unit in "${masked_units[@]}"; do
    systemctl --user unmask --runtime "$unit" >/dev/null 2>&1 || true
    rm -f "${XDG_RUNTIME_DIR:-/run/user/$UID}/systemd/user/$unit" 2>/dev/null || true
  done

  systemctl --user daemon-reload >/dev/null 2>&1 || true

  # Restore units if they were active and not persistently masked
  if (( socket_was_active == 1 )); then
    systemctl --user start "$socket" >/dev/null 2>&1 || true
  fi
  if (( service_was_active == 1 )); then
    systemctl --user start "$service" >/dev/null 2>&1 || true
  fi
}

# Signal handlers exit immediately, allowing the EXIT trap to restore units once
trap 'exit 1' INT TERM
trap cleanup EXIT

if (( service_was_active == 1 || socket_was_active == 1 )); then
  if ! systemctl --user stop "$service" "$socket"; then
    echo "Failed to stop $service or $socket before keyring repair" >&2
    exit 1
  fi
fi

# Run the offline repair
if command -v omarchy-keyring-repair >/dev/null 2>&1; then
  omarchy-keyring-repair
elif [[ -x $OMARCHY_PATH/bin/omarchy-keyring-repair ]]; then
  "$OMARCHY_PATH/bin/omarchy-keyring-repair"
else
  echo "Cannot repair keyrings: omarchy-keyring-repair is unavailable" >&2
  exit 1
fi

# Ensure dbus-broker reloads service definitions if running
if systemctl --user is-active --quiet dbus-broker.service 2>/dev/null; then
  systemctl --user reload dbus-broker.service >/dev/null 2>&1 || true
fi
