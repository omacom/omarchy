echo "Install the Broadcom wl driver for BCM43228 Wi-Fi"

# Hardware setup only runs at install. A machine already running b43 on the
# b43-firmware package works, and broadcom-wl-dkms would blacklist b43.
if omarchy-hw-x86 && [[ $(lspci -nn) == *"14e4:4359"* ]] && omarchy-pkg-missing broadcom-wl-dkms && omarchy-pkg-missing b43-firmware; then
  omarchy-pkg-add broadcom-wl-dkms
  omarchy-state set reboot-required
fi
