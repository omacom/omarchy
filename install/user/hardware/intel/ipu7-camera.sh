# Let Chromium use PipeWire camera capture on Intel IPU7 laptops.
if grep -q "OVTI08F4" /sys/bus/acpi/devices/*/hid 2>/dev/null; then
  omarchy-chromium-add-feature PipeWireCamera
fi
