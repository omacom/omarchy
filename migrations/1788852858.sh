echo "Enable GPD Pocket 4 screen rotation and boot orientation"

# install/hardware/gpd-pocket-4.sh only runs during ISO finalization. Existing
# Pocket 4 installs need the kernel cmdline, udev matrix, iio-sensor-proxy,
# and the user unit that tracks the accelerometer.

if omarchy-hw-gpd-pocket-4; then
  source "$OMARCHY_PATH/install/hardware/gpd-pocket-4.sh"
  systemctl --user daemon-reload
  systemctl --user enable --now omarchy-gpd-pocket-4-rotate.service
  omarchy-state set reboot-required
fi
