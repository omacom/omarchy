echo "Install the ASUS Zenbook A16 (UX3607OA) camera support package"

# asus-zenbook-a16-support relays the OV02C10 front camera from libcamera to a
# regular V4L2 webcam (/dev/video50) at 1080p, ships sensor black-level tuning,
# and hides raw CAMSS and IR nodes from camera pickers. Its systemd units are
# enabled by the package and start on the next boot.
if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "UX3607OA"; then
  if omarchy-pkg-missing asus-zenbook-a16-support; then
    omarchy-pkg-add asus-zenbook-a16-support
    omarchy-state set reboot-required
  fi
fi
