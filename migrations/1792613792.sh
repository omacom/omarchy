echo "Install the Broadcom wl driver for BCM4352 Wi-Fi set up before the installer covered it"

# Narrower than the leaf on purpose: the Macs on 43a0 and 4331 got wl at install, and one without it may have dropped it because it hard-freezes them (#7593).
# Only the install needs the reboot, which moves the adapter off bcma; a second user must not be told to reboot again.
pci_info=$(lspci -nn)

if [[ $pci_info =~ 14e4:43b1 ]] && omarchy-pkg-missing broadcom-wl-dkms; then
  omarchy-pkg-add broadcom-wl-dkms
  omarchy-state set reboot-required
fi
