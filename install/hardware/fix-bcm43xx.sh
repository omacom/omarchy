# Install Wi-Fi support for Broadcom chips that do not come up on their own.
# - BCM4360 (14e4:43a0, 2013–2015 MacBooks) and BCM4331 (14e4:4331) are driven
#   by the out-of-tree wl driver. b43 does not bring those chips up.
# - BCM43228 (14e4:4359) binds to in-tree b43, which then fails closed without
#   b43/ucode30_mimo.fw. That file is not in linux-firmware. wl also claims
#   this PCI ID, but broadcom-wl-dkms blacklists b43 and bcma, so it must not
#   be installed for a chip b43 already drives.

pci_info=$(lspci -nn)

if [[ $pci_info == *"14e4:43a0"* || $pci_info == *"14e4:4331"* ]]; then
  echo "BCM4360 / BCM4331 detected"
  omarchy-pkg-add broadcom-wl-dkms
fi

if [[ $pci_info == *"14e4:4359"* ]]; then
  echo "BCM43228 detected"
  omarchy-pkg-add b43-firmware
fi
