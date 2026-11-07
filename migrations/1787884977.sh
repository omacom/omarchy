echo "Set Tailscale operator so Taildrop receive can read files"

if omarchy-cmd-present tailscale; then
  # One machine-wide operator. Do not steal it from another user, and do not
  # mark this complete if sudo is cancelled or tailscaled is down.
  if ! prefs=$(sudo tailscale debug prefs 2>&1); then
    echo "Could not read Tailscale preferences: $prefs"
    echo "The Tailscale operator repair will be retried by omarchy-migrate."
    exit 1
  fi

  operator=$(printf '%s\n' "$prefs" | awk -F'"' '/"OperatorUser"/ { print $4; exit }')

  if [[ -n $operator && $operator != "$USER" ]]; then
    echo "Tailscale operator is already $operator; leaving it unchanged."
    # 1785101000 may already have started this user's receiver. It cannot
    # receive files without being the operator, so stop the access-denied loop.
    if ! error=$(systemctl --user disable --now omarchy-tailscale-receive.service 2>&1); then
      echo "Could not disable omarchy-tailscale-receive.service: $error"
      echo "The Tailscale operator repair will be retried by omarchy-migrate."
      exit 1
    fi
  else
    if [[ $operator != "$USER" ]]; then
      if ! error=$(sudo tailscale set --operator="$USER" 2>&1); then
        echo "Could not set Tailscale operator: $error"
        echo "The Tailscale operator repair will be retried by omarchy-migrate."
        exit 1
      fi
    fi

    if ! receiver_state=$(systemctl --user show --property=UnitFileState --value omarchy-tailscale-receive.service 2>&1); then
      echo "Could not read omarchy-tailscale-receive.service state: $receiver_state"
      echo "The Tailscale operator repair will be retried by omarchy-migrate."
      exit 1
    fi

    # Repair receivers enabled by 1785101000 without undoing a user's opt-out
    # or making runtime-only enablement permanent.
    if [[ $receiver_state == "enabled" || $receiver_state == "enabled-runtime" ]]; then
      systemctl --user daemon-reload >/dev/null 2>&1 || true

      if ! error=$(systemctl --user start omarchy-tailscale-receive.service 2>&1); then
        echo "Could not start omarchy-tailscale-receive.service: $error"
        echo "The Tailscale operator repair will be retried by omarchy-migrate."
        exit 1
      fi
    else
      echo "Taildrop receiver is not enabled; leaving it unchanged."
    fi
  fi
fi
