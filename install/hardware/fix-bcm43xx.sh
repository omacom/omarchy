# Install Wi-Fi drivers for Broadcom chips found in some MacBooks, as well as other systems:
# - BCM4360 (2013–2015 MacBooks)
# - BCM4331 (2012, early 2013 MacBooks)

if lspci -nn | grep -qE '14e4:(43a0|4331)'; then
  echo "BCM4360 / BCM4331 detected"
  omarchy-pkg-add broadcom-wl-dkms
fi
