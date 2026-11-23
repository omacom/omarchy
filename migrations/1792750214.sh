echo "Install the Broadcom wl driver for BCM43228 Wi-Fi"

# Hardware setup only runs at install. A machine already running b43 on the
# b43-firmware package works, and broadcom-wl-dkms would blacklist b43.
bcm43228=""
if omarchy-hw-x86 && ! bcm43228=$(lspci -n -d 14e4:4359); then
  echo "Unable to look for a BCM43228 adapter; rerun omarchy-migrate." >&2
  exit 1
fi

if [[ -n $bcm43228 ]] && omarchy-pkg-missing broadcom-wl-dkms && omarchy-pkg-missing b43-firmware; then
  omarchy-pkg-add broadcom-wl-dkms
  omarchy-state set reboot-required
fi
