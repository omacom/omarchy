echo "Fix horizontal scrolling on wired Apple Mighty Mouse (A1152)"

sudo bash "$OMARCHY_PATH/install/hardware/apple/fix-mighty-mouse-scroll.sh"

for dev in /sys/bus/usb/devices/*; do
  if [[ $(cat "$dev/idVendor" 2>/dev/null) == "05ac" && $(cat "$dev/idProduct" 2>/dev/null) == "0304" ]]; then
    echo "Log out and back in, or reboot, to load the mouse scrolling workaround."
    break
  fi
done
