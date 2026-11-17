echo "Restart the Bluetooth pairing agent so it answers pairing requests"

# The package refreshes bt-agent.service, but a running agent keeps its old
# ExecStart until the user manager reloads and the unit restarts. Restart only an
# already-active agent so intentionally inactive units stay off.

user_manager_socket="${XDG_RUNTIME_DIR:-/run/user/$UID}/systemd/private"
if ! error=$(systemctl --user show-environment 2>&1); then
  if [[ -S $user_manager_socket ]]; then
    echo "Could not reach the running user service manager: $error"
    echo "Bluetooth agent restart will be retried by omarchy-migrate."
    exit 1
  fi
  exit 0
fi

if ! error=$(systemctl --user daemon-reload 2>&1); then
  echo "Could not reload the user service manager: $error"
  echo "Bluetooth agent restart will be retried by omarchy-migrate."
  exit 1
fi

if ! agent_state=$(systemctl --user show --property=ActiveState --value bt-agent.service 2>&1); then
  echo "Could not inspect bt-agent.service: $agent_state"
  echo "Bluetooth agent restart will be retried by omarchy-migrate."
  exit 1
fi

if [[ $agent_state != "active" ]]; then
  exit 0
fi

# bt-agent ignores SIGTERM, so restart would wait out the 90s stop timeout. Kill it
# and start it; if Restart=on-failure gets there first, start has nothing to do.
if ! error=$(systemctl --user kill --signal=SIGKILL bt-agent.service 2>&1); then
  echo "Could not stop bt-agent.service: $error"
  echo "Bluetooth agent restart will be retried by omarchy-migrate."
  exit 1
fi

if ! error=$(systemctl --user start bt-agent.service 2>&1); then
  echo "Could not start bt-agent.service: $error"
  echo "Bluetooth agent restart will be retried by omarchy-migrate."
  exit 1
fi
