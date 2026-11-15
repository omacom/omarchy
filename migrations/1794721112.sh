echo "Start the Snapdragon CPU frequency floor at boot again"

# The service was wanted by multi-user.target while ordered after
# power-profiles-daemon.service, which starts after that target, so systemd
# dropped its start at every boot to break the ordering cycle. It ran only
# until the first reboot after it was installed. See
# install/hardware/qualcomm/powerprofiles-floor.sh, which installs the unit
# under graphical.target and re-enables it.
if ! omarchy-hw-aarch64-qualcomm; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/qualcomm/powerprofiles-floor.sh"
'

sudo systemctl start omarchy-powerprofiles-floor.service
