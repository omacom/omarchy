echo "Turn Apple gmux PWM off when the panel blanks on MacBookPro11,3"

# See install/hardware/apple/fix-gmux-backlight.sh, which sets up new installs
# the same way. Hyprland DPMS blanks scanout and leaves gmux PWM on.
omarchy-hw-match "MacBookPro11,3" || exit 0

sudo bash "$OMARCHY_PATH/install/hardware/apple/fix-gmux-backlight.sh"
