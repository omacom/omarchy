echo "Pre-generate shutdown-ramfs after boot for faster shutdown"

# New installs enable this in install/config/enable-services.sh. Existing
# installs wait until omarchy-settings delivers the timer unit.
if [[ ! -f /etc/systemd/system/omarchy-shutdown-ramfs.timer ]]; then
  echo "Waiting for the omarchy-settings package that ships omarchy-shutdown-ramfs.timer" >&2
  exit 75
fi

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

if ! systemctl is-enabled --quiet omarchy-shutdown-ramfs.timer 2>/dev/null; then
  if ! as_root systemctl enable --now omarchy-shutdown-ramfs.timer; then
    echo "Could not enable omarchy-shutdown-ramfs.timer; shutdown-ramfs will keep generating during shutdown." >&2
    exit 1
  fi
fi
