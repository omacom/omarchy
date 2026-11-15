echo "Start the Snapdragon CPU floor at boot, out of its ordering cycle with power-profiles-daemon"

# The floor service was wanted by multi-user.target while ordered after
# power-profiles-daemon, which orders itself after multi-user.target. systemd
# broke that cycle every boot by dropping the floor's start job.
if ! omarchy-hw-aarch64-qualcomm; then
  exit 0
fi

unit=/etc/systemd/system/omarchy-powerprofiles-floor.service

if [[ ! -e $unit ]]; then
  exit 0
fi

if ! grep -qx "WantedBy=graphical.target" "$unit"; then
  sudo install -Dm644 "$OMARCHY_PATH/default/systemd/system/omarchy-powerprofiles-floor.service" "$unit"
fi

# Outside the check so a run interrupted after the install still moves the link
sudo systemctl daemon-reload
sudo systemctl reenable omarchy-powerprofiles-floor.service

sudo systemctl start omarchy-powerprofiles-floor.service
