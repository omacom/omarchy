echo "Enable DPCD AUX backlight control on Dell XPS OLED panels"

# The kernel command line only changes in the boot image, so rebuild it here
# and ask for a reboot. Another user running this before that reboot repeats
# an identical rebuild, which is harmless.

if omarchy-hw-dell-xps-oled && omarchy-cmd-present limine-mkinitcpio; then
  source "$OMARCHY_PATH/install/hardware/dell-xps-oled-display-backlight.sh"
  sudo limine-mkinitcpio
  omarchy-state set reboot-required
fi
