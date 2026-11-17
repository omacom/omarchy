echo "Give Snapdragon power profiles a CPU frequency floor for bursty work"

# See bin/omarchy-powerprofiles-floor. Another user's run has already enabled
# the service, so it is only started.
if ! omarchy-hw-aarch64-qualcomm; then
  exit 0
fi

if [[ ! -e /etc/systemd/system/omarchy-powerprofiles-floor.service ]]; then
  sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
    source "$OMARCHY_PATH/install/hardware/qualcomm/powerprofiles-floor.sh"
  '
fi

sudo systemctl start omarchy-powerprofiles-floor.service
