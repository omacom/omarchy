echo "Restore wired Xbox controller support alongside xpadneo"

legacy_blacklist="${OMARCHY_XPAD_BLACKLIST:-/etc/modprobe.d/blacklist-xpad.conf}"

if omarchy-pkg-present xpadneo-dkms && [[ -f $legacy_blacklist ]] && [[ $(<"$legacy_blacklist") == "blacklist xpad" ]]; then
  sudo rm -f -- "$legacy_blacklist"

  # A kernel upgraded in this update has removed the running kernel's modules; udev loads xpad after the reboot.
  if ! sudo modprobe xpad; then
    echo "Reboot to load the wired Xbox controller driver."
  fi
fi
