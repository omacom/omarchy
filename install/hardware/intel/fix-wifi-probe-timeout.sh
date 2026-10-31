# Intel Wi-Fi cards can time out while their firmware starts at boot, leaving no
# Wi-Fi for the whole session. Re-probe the card at boot when that happens; see
# omarchy-hw-recover-wifi.

if lspci -d 8086::0280 | grep -q .; then
  sudo install -Dm644 "$OMARCHY_PATH/default/systemd/system/omarchy-recover-wifi.service" /etc/systemd/system/omarchy-recover-wifi.service
  sudo systemctl enable omarchy-recover-wifi.service
fi
