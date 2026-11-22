echo "Install the Surface Laptop 7 13.8\"'s Wi-Fi and Bluetooth addresses and iptsd"

# See install/hardware/microsoft/surface-laptop-7.sh. Without the addresses
# Bluetooth has no controller, and iptsd gives the touchpad its gestures and
# runs the touchscreen. Packages already installed are skipped.
if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match-device-tree microsoft,romulus13; then
  exit 0
fi

omarchy-pkg-add microsoft-surface-snapdragon-addresses iptsd
