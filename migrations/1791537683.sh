echo "Stop lid-open from soft-blocking Wi-Fi on the HP Victus 16-s1xxx"

if omarchy-hw-match "Victus by HP Gaming Laptop 16-s1"; then
  source "$OMARCHY_PATH/install/hardware/hp/fix-victus-lid-wlan.sh"

  # Reapply the keymap to the running keyboard so the fix holds before a reboot.
  sudo udevadm control --reload
  sudo udevadm trigger --subsystem-match=input --action=change --settle
fi
