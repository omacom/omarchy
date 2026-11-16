echo "Keep Wi-Fi power save on for the BCM4388 in M3 Pro MacBook Pros"

# See install/hardware/apple/wifi-powersave-bcm4388.sh for the measurement and
# why only this part is matched. Installs set up before it shipped need the same
# file, and the running link needs it applied now.
omarchy-hw-aarch64-apple || exit 0
lspci -nn | grep "14e4:4434" >/dev/null || exit 0

conf=/etc/NetworkManager/conf.d/omarchy-wifi-powersave_bcm4388.conf
if [[ ! -f $conf ]]; then
  sudo mkdir -p "$(dirname "$conf")"
  sudo tee "$conf" >/dev/null <<'CONF'
# BCM4388 on Apple Silicon: power save on (see
# install/hardware/apple/wifi-powersave-bcm4388.sh). Overrides
# omarchy-wifi-powersave.conf, which sorts before this file, for the built-in
# Wi-Fi only.
[connection-omarchy-bcm4388]
match-device=driver:brcmfmac
wifi.powersave=3
CONF
fi

sudo nmcli general reload conf >/dev/null 2>&1 || true

# NetworkManager only applies wifi.powersave when a connection activates, so
# also switch it on directly for the running session, on the BCM4388 only.
shopt -s nullglob
for wireless in /sys/class/net/*/wireless; do
  dev=$(dirname "$wireless")/device
  [[ $(cat "$dev/vendor" 2>/dev/null) == 0x14e4 && $(cat "$dev/device" 2>/dev/null) == 0x4434 ]] || continue
  iface=$(basename "$(dirname "$wireless")")
  sudo iw dev "$iface" set power_save on 2>/dev/null || true
done
