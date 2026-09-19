# This installs hardware video acceleration for Intel GPUs

if INTEL_GPU=$(lspci | grep -iE 'vga|3d|display' | grep -i 'intel'); then
  # Intel generations before Broadwell use the legacy i965 driver.
  if [[ ${INTEL_GPU,,} =~ (gma|ironlake|sandy\ bridge|2nd\ gen\ core|ivy\ bridge|3rd\ gen\ core|haswell|crystal\ well|4th\ gen\ core) ]]; then
    omarchy-pkg-add libva-intel-driver
  elif [[ ${INTEL_GPU,,} =~ (hd\ graphics|uhd\ graphics|xe|iris|arc|panther\ lake) ]]; then
    omarchy-pkg-add intel-media-driver libvpl vpl-gpu-rt
  fi
fi
