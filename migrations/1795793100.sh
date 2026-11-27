echo "Enable boot-time app.slice MemoryMax containment on >=64 GiB machines"

# Wait until omarchy-settings delivers the helper and unit.
if [[ ! -f /usr/lib/systemd/system/omarchy-high-memory.service || ! -x /usr/bin/omarchy-hw-app-slice-cap ]]; then
  echo "Waiting for the omarchy-settings package that ships omarchy-high-memory.service" >&2
  exit 75
fi

# Enable for next boot rather than starting live: writing the /run drop-in and
# reloading app.slice mid-session can OOM-kill an active workload on this or
# another user's session if usage is already above the cap.
if ! systemctl is-enabled --quiet omarchy-high-memory.service 2>/dev/null; then
  sudo systemctl enable omarchy-high-memory.service
fi

total_kib=$(awk '$1 == "MemTotal:" { print $2; exit }' /proc/meminfo 2>/dev/null || true)
if [[ $total_kib =~ ^[0-9]+$ ]] && (( total_kib >= 58720256 )) &&
  [[ ! -f /run/systemd/user/app.slice.d/10-omarchy-high-memory.conf ]]; then
  omarchy-state set reboot-required
fi
