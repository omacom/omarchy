echo "Enable boot-time app.slice MemoryMax containment on >=64 GiB machines"

# Wait until omarchy-settings delivers the helper and unit.
if [[ ! -f /usr/lib/systemd/system/omarchy-high-memory.service || ! -x /usr/bin/omarchy-hw-app-slice-cap ]]; then
  echo "Waiting for the omarchy-settings package that ships omarchy-high-memory.service" >&2
  exit 75
fi

if ! systemctl is-enabled --quiet omarchy-high-memory.service 2>/dev/null; then
  sudo systemctl enable omarchy-high-memory.service
fi

cap_bytes=$(/usr/bin/omarchy-hw-app-slice-cap --print-limit-bytes)
if [[ -z $cap_bytes ]]; then
  exit 0
fi

# Check live app.slice usage before starting the service so we never write the
# /run drop-in while an active workload exceeds the new cap (which would let
# any later unrelated `systemctl --user daemon-reload` OOM-kill it).
if systemctl --user show-environment >/dev/null 2>&1; then
  cur_bytes=$(systemctl --user show -p MemoryCurrent --value app.slice 2>/dev/null || true)
  if [[ $cur_bytes =~ ^[0-9]+$ ]] && (( cur_bytes >= cap_bytes )); then
    omarchy-state set reboot-required
    exit 0
  fi
fi

if ! systemctl is-active --quiet omarchy-high-memory.service 2>/dev/null; then
  sudo systemctl start omarchy-high-memory.service
fi

if [[ -f /run/systemd/user/app.slice.d/20-omarchy-high-memory.conf ]] &&
  systemctl --user show-environment >/dev/null 2>&1; then
  cur_max=$(systemctl --user show -p MemoryMax --value app.slice 2>/dev/null || true)
  if [[ $cur_max == "infinity" ]]; then
    systemctl --user daemon-reload
  fi
fi
