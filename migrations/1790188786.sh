echo "Install iio-sensor-proxy for the automatic keyboard backlight on laptops with an ambient light sensor"

if omarchy-hw-ambient-light; then
  omarchy-pkg-add iio-sensor-proxy
fi
