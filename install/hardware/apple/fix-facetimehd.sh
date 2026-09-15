# Pre-T2 Macs' built-in FaceTime HD camera (Broadcom 1570) has no in-tree
# driver: the PCI function sits driverless and no /dev/video exists. The
# out-of-tree bcwc_pcie driver (AUR facetimehd-dkms-git) plus Apple's camera
# firmware (AUR facetimehd-firmware) bring up /dev/video0 at 1280x720.
# Verified on MacBookPro11,5: modprobe facetimehd, three frames captured.
dmi_vendor="${OMARCHY_DMI_VENDOR:-/sys/class/dmi/id/sys_vendor}"
sys_vendor="$(cat "$dmi_vendor" 2>/dev/null || true)"

if [[ $sys_vendor == Apple* ]] && lspci -nn | grep -E "14e4:1570" >/dev/null; then
  echo "Detected pre-T2 FaceTime HD camera; installing its driver and firmware"

  omarchy-pkg-aur-add facetimehd-firmware facetimehd-dkms-git ||
    echo "Warning: could not install the FaceTime HD camera packages" >&2

  # Best-effort on a live session so the camera works without a reboot. The
  # driver's PCI alias binds it automatically on boot. Never fatal, following
  # fix-synaptic-touchpad.sh: an optional camera must not halt hardware setup,
  # and install chroots cannot load modules for the target kernel anyway.
  if modprobe -qn facetimehd 2>/dev/null; then
    modprobe facetimehd 2>/dev/null ||
      echo "Warning: could not load facetimehd (takes effect after reboot)" >&2
  fi
fi
