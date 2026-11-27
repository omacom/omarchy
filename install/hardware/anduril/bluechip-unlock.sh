# The Anduril BlueChip unlocks and logs in under its own theme's art rather than
# the Omarchy default. Only the default is replaced, so running hardware setup
# again keeps an unlock screen the user has picked since. A failure leaves the
# default in place instead of failing the install over a logo.

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree anduril,bluechip; then
  if [[ $(omarchy-plymouth-current) == "default" ]]; then
    omarchy-plymouth-set-by-theme anduril-bluechip ||
      echo "Could not set the BlueChip unlock screen; it stays on the Omarchy default"
  fi
fi
