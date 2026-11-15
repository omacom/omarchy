echo "Set up the Chuwi MiniBook X: steady touchpad, deep sleep, landscape boot screens, wake sources, auto-rotation and tablet mode"

# See install/hardware/chuwi/, which sets up new installs the same way, and
# default/hypr/chuwi-minibook-x.lua.
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1793569338}"

omarchy-hw-chuwi-minibook-x || exit 0

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  for fix in fix-minibook-x-touchpad fix-minibook-x-sleep fix-minibook-x-panel \
    fix-minibook-x-wake minibook-x-sensors; do
    source "$OMARCHY_PATH/install/hardware/chuwi/$fix.sh"
  done
'

# Apply the touchpad fuzz and the sensor rules now rather than at the next boot.
sudo udevadm control --reload
sudo udevadm trigger --action=change --subsystem-match=input
sudo udevadm trigger --action=add --subsystem-match=iio

systemctl --user daemon-reload
systemctl --user enable --now omarchy-chuwi-minibook-x-autorotate.service omarchy-chuwi-minibook-x-tablet-mode.service

# The panel orientation is a kernel argument, so the boot entries are rebuilt
# once. A marker records the machine-wide rebuild: another user's run must not
# repeat it, while a missing marker still retries an interrupted rebuild.
if [[ ! -e $rebuild_marker ]]; then
  sudo limine-update
  sudo install -Dm644 /dev/null "$rebuild_marker"
fi

omarchy-state set reboot-required
