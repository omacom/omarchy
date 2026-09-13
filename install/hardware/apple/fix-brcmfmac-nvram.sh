# Fix weak WiFi signal (-90 dBm) on MacBook Pro 2015-2017 with BCM43602 (brcmfmac)
#
# The cristianmiranda NVRAM config provides proper power amplifier settings,
# antenna gain, and board flags specific to the MacBook's hinge-antenna design.
# Without these, the card associates but signal is unusable past ~1 meter.
#
# Reference: https://github.com/omacom/omarchy/discussions/4692#discussioncomment-18081336
# Gist: https://gist.github.com/cristianmiranda/ba9d64b4324f0803d9422d765de62252

if lspci -nn | grep -q "14e4:43ba"; then
  echo "BCM43602 detected, installing improved NVRAM config for WiFi signal fix"

  nvram_file="apple/brcmfmac43602-pcie.txt"
  firmware_dir="/usr/lib/firmware/brcm"
  target="$firmware_dir/brcmfmac43602-pcie.txt"

  # Find the wireless interface and get its MAC address
  iface="$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}' | head -1)"
  if [[ -z "$iface" ]]; then
    iface="$(ls /sys/class/net/ 2>/dev/null | grep -E '^wl' | head -1)"
  fi

  # Copy the NVRAM config to a temp file for MAC substitution
  tmpfile="$(mktemp)"
  cp "$OMARCHY_INSTALL/hardware/$nvram_file" "$tmpfile"

  if [[ -n "$iface" ]]; then
    mac="$(cat "/sys/class/net/$iface/address" 2>/dev/null)"
    if [[ -n "$mac" ]]; then
      # Replace the MAC address in the NVRAM config
      sed -i "s/^macaddr=.*/macaddr=$mac/" "$tmpfile"
      echo "Set MAC address to $mac for interface $iface"
    else
      echo "Could not read MAC address from $iface, using default"
    fi
  else
    echo "No wireless interface found, using default MAC"
  fi

  # Install the NVRAM config
  mkdir -p "$firmware_dir"
  if [[ -f "$target" ]]; then
    echo "Backing up existing NVRAM config"
    cp "$target" "${target}.bak.$(date +%s)"
  fi
  install -Dm644 "$tmpfile" "$target"
  rm -f "$tmpfile"

  echo "NVRAM config installed to $target"
  echo "WiFi signal should improve after reboot (expected: -55 to -65 dBm instead of -90 dBm)"

  # Rebuild initramfs if the command exists
  if command -v limine-mkinitcpio &>/dev/null; then
    echo "Rebuilding initramfs with limine-mkinitcpio..."
    limine-mkinitcpio 2>&1 || mkinitcpio -P 2>&1
  elif command -v mkinitcpio &>/dev/null; then
    echo "Rebuilding initramfs with mkinitcpio..."
    mkinitcpio -P 2>&1
  else
    echo "No initramfs rebuild tool found. Please reboot to apply the NVRAM config."
  fi
fi
