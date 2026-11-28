echo "Apply GPD Pocket 4 boot and touchscreen orientation"

if omarchy-hw-gpd-pocket-4; then
  source "$OMARCHY_PATH/install/hardware/gpd-pocket-4.sh"

  # Boot entries must contain the new orientation before requesting reboot.
  # Fixed session orientation is supplied by the Hyprland defaults.
  sudo limine-mkinitcpio
  omarchy-state set reboot-required
fi
