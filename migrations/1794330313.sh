echo "Unlock 120/144/240/360Hz on the Razer Blade 15 Advanced (Mid 2021) 360Hz panel"

# See install/hardware/razer/fix-razer-blade15-360hz-edid.sh, which sets up new
# installs the same way. The corrected EDID loads from the initramfs, so the
# boot image is rebuilt and the new modes appear after the next reboot.
omarchy-hw-razer-blade15-360hz || exit 0

sudo OMARCHY_PATH="$OMARCHY_PATH" bash "$OMARCHY_PATH/install/hardware/razer/fix-razer-blade15-360hz-edid.sh"
sudo limine-mkinitcpio

echo "Reboot to load the corrected panel EDID, then pick a refresh rate in ~/.config/hypr/monitors.lua."
