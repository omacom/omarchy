# Front camera support for the Anduril BlueChip (Snapdragon X2 Elite / Glymur).
#
# Installs anduril-bluechip-support for the system plumbing (v4l2loopback
# module config, dma_heap udev uaccess rule, and WirePlumber rules hiding raw
# CAMSS nodes). The webcam relay and image tunings run in userland via
# omarchy-camera-tuning (started at first-run).

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree anduril,bluechip; then
  if [[ ${OMARCHY_IMAGE_DEFERRED_HARDWARE:-} == "1" ]]; then
    omarchy-pkg-add anduril-bluechip-support

    # An image's first boot runs this after boot loaded modules and finishes
    # without rebooting, so load v4l2loopback now for omarchy-camera-tuning.
    if omarchy-pkg-present anduril-bluechip-support; then
      sudo modprobe v4l2loopback || true
      sudo udevadm control --reload-rules || true
      sudo udevadm trigger --subsystem-match=dma_heap || true
    fi
  else
    OMARCHY_PKG_DEFER=1 omarchy-pkg-add anduril-bluechip-support
  fi
fi
