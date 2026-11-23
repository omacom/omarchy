echo "Install the Broadcom wl driver for BCM43224 Wi-Fi"

# Hardware setup only runs at install, so a MacBook Air 5,2 already on
# brcmsmac never receives broadcom-wl-dkms. That driver blacklists b43, so a
# machine that already installed b43-firmware for another radio is left alone.
bcm43224=""
if omarchy-hw-x86 && ! bcm43224=$(lspci -n -d 14e4:4353); then
  echo "Unable to look for a BCM43224 adapter; rerun omarchy-migrate." >&2
  exit 1
fi

if [[ -n $bcm43224 ]] && omarchy-pkg-missing broadcom-wl-dkms && omarchy-pkg-missing b43-firmware; then
  # The package blacklists brcmsmac for every kernel, so a stock fallback kernel
  # needs headers too, or it boots with no Wi-Fi driver at all.
  for kernel in linux linux-lts linux-zen linux-hardened linux-rt linux-rt-lts; do
    if omarchy-pkg-present "$kernel"; then
      omarchy-pkg-add "$kernel-headers"
    fi
  done

  omarchy-pkg-add broadcom-wl-dkms
  omarchy-state set reboot-required
fi
