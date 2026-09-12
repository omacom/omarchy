# Install Wi-Fi drivers for Broadcom chips found in some MacBooks, as well as other systems:
# - BCM4360 (2013–2015 MacBooks)
# - BCM4331 (2012, early 2013 MacBooks)

pci_info=$(lspci -nn)

if (echo "$pci_info" | grep -q "14e4:43a0" || echo "$pci_info" | grep -q "14e4:4331" || echo "$pci_info" | grep -q "14e4:4353"); then
  echo "BCM4360 / BCM4331 / BCM43224 detected"
  omarchy-pkg-add broadcom-wl-dkms linux-headers

  # Blacklist open-source drivers that conflict with wl. When b43/brcmsmac/bcma
  # load first, they claim the device and prevent wl from attaching, leaving the
  # interface down or unstable.
  mkdir -p /etc/modprobe.d
  cat > /etc/modprobe.d/broadcom-wl.conf <<'EOF'
# Blacklist open-source Broadcom drivers to prevent conflict with broadcom-wl-dkms (wl)
blacklist b43
blacklist brcmsmac
blacklist bcma
EOF
fi
