echo "Install the Surface Laptop 7 15\"'s support package on installs made before it existed"

# microsoft-surface-laptop-7-support reads the battery pack's cycle count from
# the Surface controller (surface-laptop-7-battery) and keeps the infrared
# camera out of camera pickers. Its timer checks for this laptop itself and
# starts at the next boot.
if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match-device-tree microsoft,romulus15; then
  exit 0
fi

omarchy-pkg-add microsoft-surface-laptop-7-support
