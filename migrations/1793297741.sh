echo "Re-probe an Intel Wi-Fi card whose firmware failed to start at boot"

if lspci -d 8086::0280 | grep -q .; then
  source "$OMARCHY_PATH/install/hardware/intel/fix-wifi-probe-timeout.sh"
  sudo systemctl daemon-reload
fi
