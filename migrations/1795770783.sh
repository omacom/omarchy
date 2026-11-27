echo "Keep balanced power profile on balance_performance when on battery"

dropin=/etc/tmpfiles.d/omarchy-power-profiles.conf
state_file=/var/lib/power-profiles-daemon/state.ini

# A dev checkout can run ahead of omarchy-settings: stay pending until the
# drop-in lands so fresh state resets keep battery_aware=false too.
if [[ ! -r $dropin ]]; then
  echo "Waiting for omarchy-settings to ship $dropin"
  exit 75
fi

if [[ -r $state_file ]] && grep -q '^battery_aware=false$' "$state_file"; then
  exit 0
fi

was_active=0
if systemctl is-active --quiet power-profiles-daemon.service; then
  was_active=1
  sudo systemctl stop power-profiles-daemon.service
  trap 'sudo systemctl start power-profiles-daemon.service || true' EXIT
fi

if [[ ! -f $state_file ]]; then
  sudo systemd-tmpfiles --create "$dropin"
elif grep -q '^battery_aware=' "$state_file"; then
  sudo sed -i 's/^battery_aware=.*/battery_aware=false/' "$state_file"
elif grep -q '^\[State\]$' "$state_file"; then
  sudo sed -i '/^\[State\]$/a battery_aware=false' "$state_file"
else
  sudo tee -a "$state_file" >/dev/null <<'EOF'

[State]
battery_aware=false
EOF
fi

if (( was_active )); then
  trap - EXIT
  sudo systemctl start power-profiles-daemon.service
fi
