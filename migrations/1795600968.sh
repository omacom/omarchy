echo "Isolate local AI models in their own low-priority slice"

slice_unit=/etc/systemd/user/app-models.slice
drop_in=/etc/systemd/user/omarchy-agent-local-model-.service.d/10-omarchy.conf
if [[ ! -f $slice_unit || ! -f $drop_in ]]; then
  echo "Waiting for the omarchy-settings package that ships app-models.slice" >&2
  exit 75
fi

if systemctl --user show-environment >/dev/null 2>&1; then
  systemctl --user daemon-reload

  # Do not restart running models mid-inference; notify if any are active.
  running=$(systemctl --user list-units --type=service --state=active,activating --no-legend --plain 'omarchy-agent-local-model-*.service' 2>/dev/null || true)
  if [[ -n $running ]]; then
    echo "Restart any running local AI models to apply the new slice and priorities."
  fi
fi
