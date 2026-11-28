# Wi-Fi 7 power save on the ASUS Zenbook A16 UX3607OA (Qualcomm QCC2072).
#
# Omarchy disables Wi-Fi power save globally in omarchy-wifi-powersave.conf
# because Intel BE200/BE211 firmware drops links and many cards add 20-300 ms
# idle-link latency spikes for a fraction of a watt. On the Zenbook A16's
# QCC2072 (ath12k_wifi7_pci, 6 GHz 160 MHz), power save saves ~0.73 W with
# 3.6-5.3 ms idle-link ping latency.

nm_conf_dir=${OMARCHY_ZENBOOK_A16_NM_CONF_DIR:-/etc/NetworkManager/conf.d}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "UX3607OA"; then
  mkdir -p "$nm_conf_dir"
  cat >"$nm_conf_dir/zz-zenbook-a16-wifi-powersave.conf" <<'CONF'
# Override omarchy-wifi-powersave.conf on the ASUS Zenbook A16 (QCC2072):
# saves ~0.73 W on 6 GHz 160 MHz with 3.6-5.3 ms idle-link ping latency.
[connection]
wifi.powersave = 3
CONF
fi
