# Unmask the ThinkPad Bluetooth F10 hotkey (thinkpad_acpi bit 20).

if ! omarchy-hw-match "ThinkPad" && [[ ! -d /sys/module/thinkpad_acpi ]]; then
  return 0
fi

# Copy the helper to a root-owned path before using it at boot.
sudo install -Dm644 "$OMARCHY_PATH/default/systemd/thinkpad-bluetooth-hotkey.sh" /usr/local/lib/omarchy/thinkpad-bluetooth-hotkey.sh
sudo install -Dm644 "$OMARCHY_PATH/default/systemd/system/omarchy-thinkpad-bluetooth-hotkey.service" /etc/systemd/system/omarchy-thinkpad-bluetooth-hotkey.service
sudo systemctl daemon-reload
sudo systemctl enable omarchy-thinkpad-bluetooth-hotkey.service
sudo /bin/bash /usr/local/lib/omarchy/thinkpad-bluetooth-hotkey.sh
