echo "Run the ThinkPad T14 Gen 2a (AMD) touchpad over RMI4/SMBus"

if omarchy-hw-thinkpad-t14-gen2-amd; then
  source "$OMARCHY_PATH/install/hardware/lenovo/fix-t14-gen2-amd-touchpad.sh"
  omarchy-state set reboot-required
fi
