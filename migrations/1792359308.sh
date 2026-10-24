echo "Let Chromium use the cameras of Snapdragon laptops through PipeWire"

if omarchy-hw-aarch64-qualcomm; then
  source "$OMARCHY_PATH/install/hardware/qualcomm/camera.sh"
  omarchy-install-camera

  echo "Log out and back in to load the PipeWire camera backend."
fi
