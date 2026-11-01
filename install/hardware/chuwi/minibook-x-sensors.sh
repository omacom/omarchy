# Chuwi MiniBook X: bring up both accelerometers for rotation and tablet mode.
#
# The firmware only enumerates the lid accelerometer (MDA6655). The base one,
# an MXC4005 at 0x15 on the first DesignWare I2C adapter, is instantiated once
# the lid sensor appears. Comparing the two gives the hinge angle, which
# omarchy-chuwi-minibook-x-tablet-mode uses. Tag the lid sensor as the display
# sensor so iio-sensor-proxy, which drives auto-rotation, always picks it.

rules_dir=${OMARCHY_MINIBOOK_X_RULES_DIR:-/etc/udev/rules.d}

if omarchy-hw-chuwi-minibook-x; then
  omarchy-pkg-add iio-sensor-proxy

  mkdir -p "$rules_dir"
  cat >"$rules_dir/99-omarchy-chuwi-minibook-x-accel.rules" <<'RULES'
# Chuwi MiniBook X: instantiate the base accelerometer and tag both; see
# install/hardware/chuwi/minibook-x-sensors.sh.
ACTION=="add", SUBSYSTEM=="iio", DEVPATH=="*/i2c-MDA6655:00/iio:device*", RUN+="/bin/sh -c 'for f in /sys/bus/pci/devices/0000:00:15.0/i2c_designware.0/i2c-*/new_device; do echo mxc4005 0x15 > $$f 2>/dev/null || true; done'"
ACTION=="add", SUBSYSTEM=="iio", DEVPATH=="*/i2c-MDA6655:00/*", ENV{ACCEL_LOCATION}="display"
ACTION=="add", SUBSYSTEM=="iio", DEVPATH=="*/0-0015/*", ENV{ACCEL_LOCATION}="base"
RULES
fi
