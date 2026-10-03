# Convertibles and detachables rotate the panel from the accelerometer, which
# needs iio-sensor-proxy to settle raw readings into an orientation.
if omarchy-hw-accelerometer; then
  omarchy-pkg-add iio-sensor-proxy
fi
