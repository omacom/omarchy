echo "Disable the HP ZBook Ultra G3a's phantom USB port that stalls the fingerprint reader"

# The udev rule now ships in omarchy-settings and runs on every boot. Trigger
# the root hubs once so the port goes quiet without waiting for a reboot.
if omarchy-hw-match "ZBook Ultra G3a"; then
  sudo udevadm control --reload
  sudo udevadm trigger --action=add --subsystem-match=usb --sysname-match='*-0:1.0'
  sudo udevadm settle
fi
