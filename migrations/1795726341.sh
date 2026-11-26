echo "Enable Wi-Fi power save on the ASUS Zenbook A16 (UX3607OA)"

if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "UX3607OA"; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/asus/fix-asus-zenbook-a16-wifi.sh"
  nmcli general reload conf >/dev/null 2>&1 || true

  # NetworkManager only applies wifi.powersave when a connection activates, so
  # also enable it directly for the running session unless the active profile
  # explicitly overrides 802-11-wireless.powersave (1=ignore, 2=disable).
  shopt -s nullglob
  for wireless in /sys/class/net/*/wireless; do
    iface=$(basename "$(dirname "$wireless")")
    conn=$(nmcli -g GENERAL.CONNECTION dev show "$iface" 2>/dev/null || true)
    powersave=""
    if [[ -n $conn && $conn != "--" ]]; then
      powersave=$(nmcli -g 802-11-wireless.powersave con show "$conn" 2>/dev/null || true)
    fi
    if [[ -z $powersave || $powersave == 0* || $powersave == 3* || $powersave == "default" || $powersave == "enable" ]]; then
      iw dev "$iface" set power_save on 2>/dev/null || true
    fi
  done
'
