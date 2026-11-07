echo "Install b43-firmware on BCM4322 MacBooks so Wi-Fi gets a wlan interface"

# Older AirPort Extreme (BCM4322) loads b43 but needs AUR firmware linux-firmware lacks.
if omarchy-cmd-present lspci && lspci -nn | grep -q "14e4:432b"; then
  if omarchy-pkg-aur-accessible; then
    omarchy-pkg-aur-add b43-firmware || true
  fi
fi
