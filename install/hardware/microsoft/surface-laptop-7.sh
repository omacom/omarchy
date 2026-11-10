# Microsoft Surface Laptop 7 15" (Snapdragon X Elite) touchpad. The kernel alone
# runs the pad as a mouse. iptsd adds two-finger scroll, pinch and two-finger
# tap, though pressing the pad stops registering as a click.

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree microsoft,romulus15; then
  omarchy-pkg-add iptsd
fi
