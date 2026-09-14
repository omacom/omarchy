# Install Wi-Fi drivers for Broadcom chips found in some MacBooks, as well as other systems:
# - BCM4360 (2013–2015 MacBooks)
# - BCM4352 (Dell XPS 13 9343, among others)
# - BCM4331 (2012, early 2013 MacBooks)

pci_info=$(lspci -nn)

if [[ $pci_info =~ 14e4:(43a0|43b1|4331) ]]; then
  echo "Broadcom adapter requiring wl detected"
  omarchy-pkg-add broadcom-wl-dkms linux-headers
fi
