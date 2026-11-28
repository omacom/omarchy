echo "Install the Anduril BlueChip camera support package"

# anduril-bluechip-support relays the OV08X40 front camera from libcamera to a
# regular V4L2/PipeWire webcam (/dev/video50) at 1080p, ships sensor black-level
# tuning and DMA heap access, and hides raw CAMSS nodes from camera pickers. Its
# systemd units are enabled by the package and start on the next boot.
if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree anduril,bluechip; then
  if omarchy-pkg-missing anduril-bluechip-support; then
    omarchy-pkg-add anduril-bluechip-support
    omarchy-state set reboot-required
  fi
fi
