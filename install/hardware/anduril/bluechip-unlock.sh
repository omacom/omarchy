# The Anduril BlueChip unlocks and logs in under its own theme's art rather than
# the Omarchy default. Another theme's screen picked since is kept; a return to
# the default cannot be told from a fresh install and is replaced again. A
# failure leaves the default in place instead of failing the install over a logo.

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree anduril,bluechip; then
  if [[ $(omarchy-plymouth-current) == "default" ]]; then
    if omarchy-plymouth-set-by-theme anduril-bluechip; then
      # An image's first boot rebuilds after its last step, but does not watch
      # the Plymouth theme.
      if [[ -n ${OMARCHY_IMAGE_BOOT_REBUILD:-} ]]; then
        : >"$OMARCHY_IMAGE_BOOT_REBUILD"
      fi
    else
      echo "Could not set the BlueChip unlock screen; it stays on the Omarchy default"
    fi
  fi
fi
