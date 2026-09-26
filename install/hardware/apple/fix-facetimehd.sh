#!/bin/bash

set -euo pipefail

# Install the out-of-tree driver and firmware for Apple's Broadcom 1570 PCIe camera.
# This is the camera used by the 720p FaceTime HD device in Intel MacBooks such
# as the MacBook Air A1466; it is not a USB camera and is not handled by uvcvideo.

pci_info=$(lspci -nn)

run_as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

if grep -q '14e4:1570' <<<"$pci_info"; then
  echo "Broadcom 1570 FaceTime HD camera detected"
  omarchy-pkg-aur-add facetimehd-dkms
  omarchy-pkg-add linux-headers

  modules_dir="${OMARCHY_FACETIMEHD_MODULES_DIR:-/etc/modules-load.d}"
  run_as_root install -d "$modules_dir"
  printf '%s\n' facetimehd | run_as_root tee "$modules_dir/facetimehd.conf" >/dev/null

  # The generic bdc_pci driver can claim this PCI function before facetimehd.
  # facetimehd's DKMS package blacklists it for future boots; unload it here as
  # well so an already-running install can use the camera without rebooting.
  run_as_root modprobe -r bdc_pci 2>/dev/null || true
  run_as_root modprobe facetimehd 2>/dev/null || true
fi
