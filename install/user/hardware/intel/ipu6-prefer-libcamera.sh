# Route the IPU6 camera through libcamera instead of its raw v4l2 nodes, so
# browsers stop picking a black or green Bayer node. See the drop-in for why
# this disables the monitor rather than the device.

if omarchy-hw-intel-ipu6; then
  mkdir -p ~/.config/wireplumber/wireplumber.conf.d/
  cp "$OMARCHY_PATH/default/wireplumber/wireplumber.conf.d/ipu6-prefer-libcamera.conf" ~/.config/wireplumber/wireplumber.conf.d/
fi
