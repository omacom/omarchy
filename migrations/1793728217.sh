echo "Configure ASUS Vivobook S 15 hardware support (boot, sleep, audio, cameras, hotkeys)"

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "S5507"; then
  sudo /bin/bash "$OMARCHY_PATH/install/hardware/asus/fix-asus-vivobook-s15.sh"
  sudo limine-update || true
fi
