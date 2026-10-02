echo "Install the touchpad resume hook on ASUS Zenbook 14 UM3406"

if omarchy-hw-match "UM3406"; then
  source "$OMARCHY_PATH/install/hardware/asus/fix-asus-um3406-touchpad-resume.sh"
fi
