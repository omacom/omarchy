echo "Fix display brightness controls on the ASUS ROG Zephyrus G16 GU605MY"

backlight_conf="${OMARCHY_GU605MY_BACKLIGHT_CONF:-/etc/limine-entry-tool.d/asus-gu605my-display-backlight.conf}"

if omarchy-hw-match "GU605MY" && omarchy-cmd-present limine-mkinitcpio && [[ ! -f $backlight_conf ]]; then
  source "$OMARCHY_PATH/install/hardware/asus/fix-asus-gu605my-display-backlight.sh"
  sudo limine-mkinitcpio
  omarchy-state set reboot-required
fi
