echo "Enable typing suppression on the MacBookPro11,3 trackpad"

source "$OMARCHY_PATH/install/hardware/apple/fix-touchpad-typing.sh"

# libinput must reopen the device with its corrected udev classification.
# Keep the running session intact; the next boot applies it.
if (( macbook_touchpad_hwdb_changed )); then
  omarchy-state set reboot-required
fi
