# This installs hardware video acceleration for Intel GPUs

if omarchy-hw-pci --class 03 8086:* && INTEL_GPU=$(lspci -d 8086: | grep -iE 'vga|3d|display' | grep -i 'intel'); then
  # HD Graphics / Iris / Xe / Arc use intel-media-driver + VPL, as do the newer
  # GPUs that lspci names only "[Intel Graphics]" (non-Arc Panther Lake, Wildcat Lake)
  if [[ ${INTEL_GPU,,} =~ (hd\ graphics|uhd\ graphics|xe|iris|arc|panther\ lake|\[intel\ graphics) ]]; then
    OMARCHY_PKG_DEFER=1 omarchy-pkg-add intel-media-driver libvpl vpl-gpu-rt
  elif [[ ${INTEL_GPU,,} =~ "gma" ]]; then
    # Older generations from 2008 to ~2014-2017 use libva-intel-driver
    OMARCHY_PKG_DEFER=1 omarchy-pkg-add libva-intel-driver
  fi
fi
