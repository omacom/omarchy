echo "Install Broadcom b43 firmware for BCM43228 Wi-Fi"

# Existing installs keep the broken probe until the firmware package is
# installed. b43-firmware is published from omarchy-pkgs; until that package
# is in the configured repositories this migration stays pending rather than
# recording a success that would never retry. Machines that already have the
# package, including the AUR build of the same name, are left alone.
pci_info=$(lspci -nn)
if [[ $pci_info == *"14e4:4359"* ]] && omarchy-pkg-missing b43-firmware; then
  if ! pacman -Si -- b43-firmware &>/dev/null; then
    echo "b43-firmware is not in the configured repositories yet" >&2
    exit 1
  fi
  omarchy-pkg-add b43-firmware
  omarchy-state set reboot-required
fi
