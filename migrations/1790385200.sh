echo "Activate the Omarchy Bluetooth pairing agent"

# Package updates refresh the unit file and shell, but leave a running
# bluez-tools bt-agent process in place. Reload the user manager and restart
# only an already-active agent so intentionally inactive units stay off.

user_manager_socket="${XDG_RUNTIME_DIR:-/run/user/$UID}/systemd/private"
if ! error=$(systemctl --user show-environment 2>&1); then
  if [[ -S $user_manager_socket ]]; then
    echo "Could not reach the running user service manager: $error"
    echo "Bluetooth agent activation will be retried by omarchy-migrate."
    exit 1
  fi
  exit 0
fi

if ! error=$(systemctl --user daemon-reload 2>&1); then
  echo "Could not reload the user service manager: $error"
  echo "Bluetooth agent activation will be retried by omarchy-migrate."
  exit 1
fi

if ! agent_state=$(systemctl --user show --property=ActiveState --value bt-agent.service 2>&1); then
  echo "Could not inspect bt-agent.service: $agent_state"
  echo "Bluetooth agent activation will be retried by omarchy-migrate."
  exit 1
fi

if [[ $agent_state != "active" ]]; then
  exit 0
fi

if ! error=$(systemctl --user restart bt-agent.service 2>&1); then
  echo "Could not restart bt-agent.service: $error"
  echo "Bluetooth agent activation will be retried by omarchy-migrate."
  exit 1
fi
