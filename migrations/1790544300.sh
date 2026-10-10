echo "Unmask the ThinkPad Bluetooth F10 hotkey (thinkpad_acpi bit 20)"

# Replace the earlier all-bits drop-in if a previous migration left one behind.
if [[ -f /etc/modprobe.d/omarchy-thinkpad-hotkey.conf ]]; then
  sudo rm -f /etc/modprobe.d/omarchy-thinkpad-hotkey.conf
fi

if ! omarchy-hw-match "ThinkPad" && [[ ! -d /sys/module/thinkpad_acpi ]]; then
  exit 0
fi

source "$OMARCHY_PATH/install/hardware/lenovo/fix-thinkpad-bluetooth-hotkey.sh"
