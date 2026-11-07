echo "Stop the watchdog timeout error Snapdragon laptops print at shutdown"

# See install/hardware/qualcomm/reboot-watchdog.sh. systemd reads it at the
# next boot, so the shutdown after that one is the first without the error.
if ! omarchy-hw-aarch64-qualcomm; then
  exit 0
fi

# Another user's run already wrote it.
if grep -Fqx "RebootWatchdogSec=off" /etc/systemd/system.conf.d/60-omarchy-qualcomm-reboot-watchdog.conf 2>/dev/null; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/qualcomm/reboot-watchdog.sh"
'
