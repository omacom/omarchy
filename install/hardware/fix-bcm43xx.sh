# Install Wi-Fi drivers for Broadcom chips found in some MacBooks, as well as other systems:
# - BCM4360 (2013–2015 MacBooks)
# - BCM4331 (2012, early 2013 MacBooks)
# - BCM43224 (2012 MacBook Air 5,2)

pci_info=$(lspci -nn)

if (echo "$pci_info" | grep -q "14e4:43a0" || echo "$pci_info" | grep -q "14e4:4331" || echo "$pci_info" | grep -q "14e4:4353"); then
  echo "BCM4360 / BCM4331 / BCM43224 detected"
  omarchy-pkg-add broadcom-wl-dkms
fi
