echo "Protect desktop session file cache and tighten OOM pressure response"

# Wait until omarchy-settings delivers the updated configs and drop-ins.
for req in \
  /etc/systemd/system/user.slice.d/10-omarchy-memory.conf \
  /etc/systemd/system/user-.slice.d/10-omarchy-memory.conf \
  /etc/systemd/system/user@.service.d/20-omarchy-memory.conf \
  /etc/systemd/user.conf.d/30-omarchy-oom.conf \
  /etc/systemd/user/wayland-wm@.service.d/10-omarchy-oom.conf; do
  if [[ ! -f $req ]]; then
    echo "Waiting for the omarchy-settings package that ships $req" >&2
    exit 75
  fi
done

if ! grep -Fqx 'SwapUsedLimit=80%' /etc/systemd/oomd.conf.d/10-omarchy.conf 2>/dev/null ||
  ! grep -Fqx 'MemoryLow=768M' /etc/systemd/user/session.slice.d/10-omarchy.conf 2>/dev/null ||
  ! grep -Fqx 'vm.swappiness=100' /etc/sysctl.d/99-omarchy-sysctl.conf 2>/dev/null; then
  echo "Waiting for the omarchy-settings package that ships the updated memory tuning" >&2
  exit 75
fi

# Raise vm.swappiness from the previous Omarchy default (1) to 100 without
# overwriting custom user values set by higher-priority sysctl drop-ins.
cur_swappiness=$(sysctl -n vm.swappiness 2>/dev/null || true)
if [[ $cur_swappiness == "1" ]]; then
  sudo sysctl -q -w vm.swappiness=100
fi

sudo systemctl daemon-reload

if systemctl is-active --quiet systemd-oomd.service 2>/dev/null; then
  sudo systemctl try-restart systemd-oomd.service
fi

if systemctl --user show-environment >/dev/null 2>&1; then
  systemctl --user daemon-reload
fi
