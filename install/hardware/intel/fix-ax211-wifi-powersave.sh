# Wi-Fi 6E power save on Intel Meteor Lake CNVi Wi-Fi (AX211, PCI 8086:7e40).
#
# Omarchy disables Wi-Fi power save globally in omarchy-wifi-powersave.conf
# because Intel BE200/BE211 firmware drops links and many cards add 20-300 ms
# idle-link latency spikes for a fraction of a watt. On Meteor Lake's AX211
# (iwlmvm, 6 GHz 160 MHz), power save unlocks Package C10 and saves ~0.7 W
# with 6.4 ms avg / 8.7 ms max idle-link ping latency.

nm_conf_dir=${OMARCHY_INTEL_AX211_NM_CONF_DIR:-/etc/NetworkManager/conf.d}

if omarchy-hw-pci 8086:7e40; then
  mkdir -p "$nm_conf_dir"
  cat >"$nm_conf_dir/zz-intel-ax211-wifi-powersave.conf" <<'CONF'
# Override omarchy-wifi-powersave.conf on Intel Meteor Lake CNVi Wi-Fi 6E (AX211):
# unlocks Package C10 and saves ~0.7 W on 6 GHz 160 MHz with 6.4 ms avg / 8.7 ms max
# idle-link ping latency.
[connection]
wifi.powersave = 3
CONF
fi
