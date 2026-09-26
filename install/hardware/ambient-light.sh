# Install iio-sensor-proxy so the shell can read the ambient light sensor, which
# drives the automatic keyboard backlight.
if omarchy-hw-ambient-light && omarchy-hw-keyboard-backlight; then
  omarchy-pkg-add iio-sensor-proxy
fi
