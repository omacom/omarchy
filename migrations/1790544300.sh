echo "Unmask the ThinkPad Bluetooth F10 hotkey (thinkpad_acpi bit 20)"

if ! omarchy-hw-match "ThinkPad" && [[ ! -d /sys/module/thinkpad_acpi ]]; then
  exit 0
fi

source "$OMARCHY_PATH/install/hardware/lenovo/fix-thinkpad-bluetooth-hotkey.sh"
