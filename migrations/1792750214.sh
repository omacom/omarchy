echo "Install the Broadcom wl driver for BCM43228 Wi-Fi"

# Hardware setup only runs at install. A machine already running b43 on firmware
# its owner added works, and broadcom-wl-dkms would blacklist b43.
if [[ $(lspci -nn) == *"14e4:4359"* && ! -d /usr/lib/firmware/b43 ]] && omarchy-pkg-missing broadcom-wl-dkms; then
  omarchy-pkg-add broadcom-wl-dkms
  omarchy-state set reboot-required
fi
