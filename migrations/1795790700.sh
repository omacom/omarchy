echo "Protect desktop session file cache and tighten OOM pressure response"

# Gate only on the newly shipped non-backup drop-ins so customized pacman
# backup files (like /etc/systemd/oomd.conf.d/10-omarchy.conf) never trap the
# migration queue in exit 75.
for req in \
  /etc/systemd/system/user.slice.d/10-omarchy-memory.conf \
  /etc/systemd/system/user-.slice.d/10-omarchy-memory.conf \
  /etc/systemd/system/user@.service.d/20-omarchy-memory.conf; do
  if [[ ! -f $req ]]; then
    echo "Waiting for the omarchy-settings package that ships $req" >&2
    exit 75
  fi
done

uid=$(id -u)
system_reload_needed=0
for unit in user.slice "user-$uid.slice" "user@$uid.service"; do
  cur_low=$(systemctl show -p MemoryLow --value "$unit" 2>/dev/null || true)
  if [[ $cur_low != "805306368" ]]; then
    system_reload_needed=1
    break
  fi
done

oomd_restart_needed=0
if systemctl is-active --quiet systemd-oomd.service 2>/dev/null &&
  grep -Fqx 'DefaultMemoryPressureLimit=60%' /etc/systemd/oomd.conf.d/10-omarchy.conf 2>/dev/null &&
  grep -Fqx 'DefaultMemoryPressureDurationSec=10s' /etc/systemd/oomd.conf.d/10-omarchy.conf 2>/dev/null; then
  oomd_status=$(oomctl 2>/dev/null || true)
  if [[ $oomd_status != *"Default Memory Pressure Limit: 60.00%"* ||
    $oomd_status != *"Default Memory Pressure Duration: 10s"* ]]; then
    oomd_restart_needed=1
  fi
fi

if (( system_reload_needed == 1 )); then
  sudo systemctl daemon-reload
fi

if (( oomd_restart_needed == 1 )); then
  sudo systemctl try-restart systemd-oomd.service
fi

if systemctl --user show-environment >/dev/null 2>&1; then
  cur_session_low=$(systemctl --user show -p MemoryLow --value session.slice 2>/dev/null || true)
  if [[ $cur_session_low != "805306368" ]]; then
    systemctl --user daemon-reload
  fi
fi
