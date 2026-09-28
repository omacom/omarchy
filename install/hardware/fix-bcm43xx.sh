# Install Wi-Fi drivers for Broadcom chips found in some MacBooks, as well as other systems:
# - BCM4360 (14e4:43a0, 2013–2015 MacBooks) has no in-kernel driver. broadcom-wl is the only option.
# - BCM4331 (14e4:4331, 2011–early 2013 MacBooks) is driven by in-kernel b43.
#   broadcom-wl hard-freezes these machines and blacklists b43, so it must not be
#   installed when a BCM4331 is present. linux-firmware-broadcom does not ship the
#   b43 ucode (it is the brcmfmac/bnx2 split), so this script does not add a package
#   that would claim to provide it.

pci_info=$(lspci -nn)

if echo "$pci_info" | grep -q "14e4:4331"; then
  echo "BCM4331 detected; leaving in-kernel b43 in place"
elif echo "$pci_info" | grep -q "14e4:43a0"; then
  echo "BCM4360 detected"
  omarchy-pkg-add broadcom-wl-dkms
fi
