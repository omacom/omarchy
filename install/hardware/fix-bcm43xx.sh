# Install Wi-Fi drivers for Broadcom chips found in some MacBooks, as well as other systems:
# - BCM4360 (2013–2015 MacBooks)
# - BCM4331 (2012, early 2013 MacBooks)
# - BCM4321 (2007–2008 iMacs and MacBooks; 4329 and 432a are the same chip)

pci_info=$(lspci -nn)

if echo "$pci_info" | grep -qE "14e4:(43a0|4331|4328|4329|432a)"; then
  echo "Broadcom BCM4360 / BCM4331 / BCM4321 detected"
  omarchy-pkg-add broadcom-wl-dkms linux-headers
fi
