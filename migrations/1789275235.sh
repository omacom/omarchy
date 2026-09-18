echo "Install the package-owned Apple Wi-Fi default"

if omarchy-hw-apple-silicon; then
  # Install from the signed sync repository; do not fall back to the AUR.
  # Publication of the matching settings add-on precedes this runtime update.
  omarchy-update-pacman -S --needed --noconfirm omarchy-settings-asahi
fi
