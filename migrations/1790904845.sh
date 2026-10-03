echo "Install the Dell XPS 13 Panther Lake speaker firmware"

if omarchy-hw-dell-xps13-dx13260-ptl; then
  source "$OMARCHY_PATH/install/hardware/dell-xps13-ptl-speaker-firmware.sh"

  # The marker lasts until reboot so every user migrating beforehand is prompted.
  firmware_pending="/run/omarchy/xps13-ptl-speaker-firmware"
  if [[ -e $firmware_pending ]]; then
    omarchy-state set reboot-required
  fi
fi
