# Clear the hardware Wi-Fi rfkill block asserted by the MSI GS65 Stealth
# Embedded Controller (MS-16Q2 / MS-16Q4) across S3 suspend and resume.

if omarchy-hw-match "^GS65 Stealth"; then
  sudo install -Dm755 -o root -g root \
    "$OMARCHY_PATH/default/systemd/system-sleep/msi-gs65-wifi" \
    /usr/lib/systemd/system-sleep/msi-gs65-wifi
fi
