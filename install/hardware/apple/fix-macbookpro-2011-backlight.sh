# Firmware must already have disabled the failed AMD GPU. Never change the
# mux, EFI variables or GPU power state on a healthy dual-GPU MacBook.
if omarchy-hw-match '^MacBookPro8,2$'; then
  has_amd_display=false
  has_hd3000=false
  for device in "${OMARCHY_PCI_DEVICES:-/sys/bus/pci/devices}"/*; do
    vendor=$(cat "$device/vendor" 2>/dev/null || true)
    class=$(cat "$device/class" 2>/dev/null || true)
    [[ $class == 0x03* ]] || continue
    if [[ $vendor == "0x1002" ]]; then
      has_amd_display=true
    elif [[ $vendor == "0x8086" && $(cat "$device/device" 2>/dev/null) == "0x0126" ]]; then
      has_hd3000=true
    fi
  done

  if $has_hd3000 && ! $has_amd_display; then
    omarchy-pkg-add lp8545-backlight-dkms
    # An image's modules-load already ran before first-boot provisioning.
    # Chroot installs pick it up at the installed system's next boot.
    if [[ ${OMARCHY_IMAGE_DEFERRED_HARDWARE:-0} == "1" ]]; then
      modprobe lp8545_bl
    fi
  fi
fi
