echo "Reload systemd to apply kernel module cleanup hardening"

reload_needed=$(systemctl show --property=NeedDaemonReload --value linux-modules-cleanup.service)

if [[ $reload_needed == "yes" ]]; then
  sudo systemctl daemon-reload
elif [[ $reload_needed != "no" ]]; then
  echo "Could not determine whether linux-modules-cleanup.service needs a daemon reload" >&2
  exit 1
fi
