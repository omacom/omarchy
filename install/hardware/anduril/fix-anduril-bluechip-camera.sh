# Front camera relay, tuning and picker cleanup for the Anduril BlueChip
# (Snapdragon X2 Elite / Glymur).
#
# The OV08X40 RGB camera runs through libcamera's simple pipeline and software
# ISP, so apps that read V4L2 cameras only (Monologue, Qt Multimedia) need the
# v4l2-relayd loopback relay that anduril-bluechip-support sets up, along with
# sensor black-level tuning, DMA heap udev access, and WirePlumber rules to
# hide raw CAMSS nodes.

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree anduril,bluechip; then
  if [[ ${OMARCHY_IMAGE_DEFERRED_HARDWARE:-} == "1" ]]; then
    omarchy-pkg-add anduril-bluechip-support

    # An image's first boot runs this after boot queued its units and finishes
    # without rebooting, so load v4l2loopback and start the relay + guard now.
    if omarchy-pkg-present anduril-bluechip-support; then
      sudo modprobe v4l2loopback || true
      sudo systemctl daemon-reload || true
      sudo systemctl start --no-block v4l2-relayd@bluechip.service bluechip-camera-guard.service || true
    fi
  else
    OMARCHY_PKG_DEFER=1 omarchy-pkg-add anduril-bluechip-support
  fi
fi
