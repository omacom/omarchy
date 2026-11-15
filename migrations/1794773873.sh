echo "Install the Broadcom wl driver for BCM43224 Wi-Fi"

# Hardware setup only runs at install, so a MacBook Air 5,2 already on
# brcmsmac never receives broadcom-wl-dkms. That driver blacklists b43, so a
# machine that already installed b43-firmware for another radio is left alone.
if omarchy-hw-x86 && [[ $(lspci -nn) == *"14e4:4353"* ]] && omarchy-pkg-missing broadcom-wl-dkms && omarchy-pkg-missing b43-firmware; then
  omarchy-pkg-add broadcom-wl-dkms
  omarchy-state set reboot-required
fi
