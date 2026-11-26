echo "Install the FaceTime HD camera driver on Intel Macs that have one"

# Fresh installs get this from install/hardware/apple/fix-facetimehd.sh. Existing
# Macs only pick it up on omarchy update via this migration.
if omarchy-hw-facetimehd; then
  source "$OMARCHY_PATH/install/hardware/apple/fix-facetimehd.sh"

  # The module only loads at boot, so the camera stays missing until then.
  (( ${#packages[@]} == 0 )) || omarchy-state set reboot-required

  # The leaf only enables the fetch for the next boot; on a running system it can start now.
  if pacman -Q facetimehd-firmware-fetcher &>/dev/null; then
    sudo systemctl start --no-block facetimehd-firmware-fetcher.service
  fi
fi
