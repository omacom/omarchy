# Install Wi-Fi drivers for Broadcom chips found in some MacBooks, as well as other systems:
# - BCM4360 (2013–2015 MacBooks)
# - BCM4331 (2012, early 2013 MacBooks)
#
# Preserve installed drivers. Fresh BCM4360 setup can use the WPA3 package
# once published; BCM4331 and mixed cards keep the stock package.

pci_info=$(lspci -nn)

if omarchy-hw-x86 && [[ $pci_info =~ \[14e4:(43a0|4331)\] ]]; then
  if omarchy-pkg-present broadcom-wl-wpa3-dkms; then
    echo "Broadcom WPA3 driver already installed"
  elif omarchy-pkg-present broadcom-wl-dkms; then
    echo "Broadcom stock driver already installed; keeping it"
  elif [[ $pci_info =~ \[14e4:4331\] ]]; then
    echo "BCM4331 detected"
    omarchy-pkg-add broadcom-wl-dkms
  elif pacman -Si broadcom-wl-wpa3-dkms >/dev/null 2>&1; then
    echo "BCM4360 detected; installing WPA3/PMF driver"
    omarchy-pkg-add broadcom-wl-wpa3-dkms
  else
    echo "BCM4360 detected; WPA3 package unavailable, using stock"
    omarchy-pkg-add broadcom-wl-dkms
  fi
fi
