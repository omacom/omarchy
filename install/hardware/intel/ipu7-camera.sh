# Install MIPI camera support for Intel IPU7 hardware
#
# intel-ipu7-camera drives the ov08x40 (OVTI08F4) and, on Lunar Lake, the Sony
# IMX471 (SONY471A) fitted to the Lenovo ThinkPad X9 Gen 1. Firmware tables list
# sensors a board does not carry, so the IMX471 counts only when its ACPI _STA
# says the device is present.
acpi_devices="${OMARCHY_ACPI_DEVICES_PATH:-/sys/bus/acpi/devices}"

ipu7_camera_sensor=0
if grep -q "OVTI08F4" "$acpi_devices"/*/hid 2>/dev/null; then
  ipu7_camera_sensor=1
fi
for imx471 in "$acpi_devices"/SONY471A:*; do
  if [[ -r $imx471/status ]] && (( $(<"$imx471/status") & 1 )); then
    ipu7_camera_sensor=1
  fi
done

if (( ipu7_camera_sensor )); then
  omarchy-pkg-add intel-ipu7-camera
fi

unset acpi_devices ipu7_camera_sensor imx471
