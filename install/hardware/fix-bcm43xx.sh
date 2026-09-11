# Install Wi-Fi drivers for Broadcom chips found in some MacBooks, as well as other systems:
# - BCM4360 (2013–2015 MacBooks) / BCM4331 (2012, early 2013): proprietary STA via broadcom-wl-dkms
# - BCM4322 (older AirPort Extreme, PCI 14e4:432b): in-tree b43 needs AUR b43-firmware

pci_info=$(lspci -nn)

if (echo "$pci_info" | grep -q "14e4:43a0" || echo "$pci_info" | grep -q "14e4:4331"); then
  echo "BCM4360 / BCM4331 detected"
  omarchy-pkg-add broadcom-wl-dkms linux-headers
fi

# BCM4322 (and the open b43 path) needs cut firmware that linux-firmware does not ship.
# Without it, dmesg reports missing b43/ucode16_mimo.fw and no wlan interface appears.
if echo "$pci_info" | grep -q "14e4:432b"; then
  echo "BCM4322 detected (b43 firmware required)"
  if omarchy-pkg-aur-accessible; then
    omarchy-pkg-aur-add b43-firmware
  else
    echo "AUR unavailable; install b43-firmware later so BCM4322 Wi-Fi can load firmware"
  fi
fi
