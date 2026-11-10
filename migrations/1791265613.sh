echo "Install the Dell XPS 13 Panther Lake speaker firmware"

if omarchy-hw-dell-xps13-dx13260-ptl; then
  source "$OMARCHY_PATH/install/hardware/dell-xps13-ptl-speaker-firmware.sh"
  omarchy-state set reboot-required
fi
