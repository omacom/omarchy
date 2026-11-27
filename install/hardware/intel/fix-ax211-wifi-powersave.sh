# Wi-Fi 6E power save on Intel Meteor Lake CNVi Wi-Fi (AX211, PCI 8086:7e40).
#
# Omarchy disables Wi-Fi power save globally in omarchy-wifi-powersave.conf
# because Intel BE200/BE211 firmware drops links and many cards add 20-300 ms
# idle-link latency spikes for a fraction of a watt. On Meteor Lake's AX211
# (iwlmvm, 6 GHz 160 MHz), power save unlocks Package C10 and saves ~0.7 W
# with 6.4 ms avg / 8.7 ms max idle-link ping latency.

nm_conf_dir=${OMARCHY_INTEL_AX211_NM_CONF_DIR:-/etc/NetworkManager/conf.d}
pci_devices_path=${OMARCHY_PCI_DEVICES_PATH:-/sys/bus/pci/devices}

if omarchy-hw-pci 8086:7e40; then
  ax211_match=()
  shopt -s nullglob
  for device in "$pci_devices_path"/*; do
    [[ -r $device/vendor && -r $device/device ]] || continue
    vendor=$(<"$device/vendor")
    dev_id=$(<"$device/device")
    [[ ${vendor,,} == "0x8086" && ${dev_id,,} == "0x7e40" ]] || continue
    for net_dir in "$device"/net/*; do
      [[ -d $net_dir ]] || continue
      ax211_match+=("interface-name:=$(basename "$net_dir")")
    done
  done
  shopt -u nullglob

  if (( ${#ax211_match[@]} > 0 )); then
    match_spec=$(IFS=,; printf '%s' "${ax211_match[*]}")
    mkdir -p "$nm_conf_dir"
    printf '%s\n' \
      '# Override omarchy-wifi-powersave.conf on Intel Meteor Lake CNVi Wi-Fi 6E (AX211):' \
      '# unlocks Package C10 and saves ~0.7 W on 6 GHz 160 MHz with 6.4 ms avg / 8.7 ms max' \
      '# idle-link ping latency. Scoped to the 8086:7e40 device so other adapters keep the' \
      '# global wifi.powersave = 2 protection.' \
      '[connection-intel-ax211-wifi-powersave]' \
      "match-device=$match_spec" \
      'wifi.powersave = 3' \
      >"$nm_conf_dir/zz-intel-ax211-wifi-powersave.conf"
  fi
fi
