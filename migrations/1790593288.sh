echo "Install iio-sensor-proxy so convertibles can rotate with the accelerometer"

# New installs get this from install/hardware/accelerometer.sh. Existing ones need
# it before the autorotate daemon in the session has a sensor to read; machines
# without an accelerometer skip it, and the daemon exits on them either way.
if omarchy-hw-accelerometer; then
  omarchy-pkg-add iio-sensor-proxy
fi
