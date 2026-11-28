echo "Enable Wi-Fi power save on Intel Meteor Lake CNVi Wi-Fi 6E (AX211)"

if ! omarchy-hw-pci 8086:7e40; then
  exit 0
fi

if [[ -f /etc/NetworkManager/conf.d/zz-intel-ax211-wifi-powersave.conf ]]; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/intel/fix-ax211-wifi-powersave.sh"
  nmcli general reload conf >/dev/null 2>&1 || true

  # NetworkManager only applies wifi.powersave when a connection activates, so
  # also enable it directly for the running session on the matching 8086:7e40
  # device unless its active profile explicitly overrides 802-11-wireless.powersave
  # (1=ignore, 2=disable).
  shopt -s nullglob
  for device in /sys/bus/pci/devices/*; do
    [[ -r $device/vendor && -r $device/device ]] || continue
    vendor=$(<"$device/vendor")
    dev_id=$(<"$device/device")
    [[ ${vendor,,} == "0x8086" && ${dev_id,,} == "0x7e40" ]] || continue

    for net_dir in "$device"/net/*; do
      [[ -d $net_dir/wireless ]] || continue
      iface=$(basename "$net_dir")
      uuid=$(nmcli -g GENERAL.CON-UUID dev show "$iface" 2>/dev/null || true)
      powersave=""
      if [[ -n $uuid && $uuid != "--" ]]; then
        if ! powersave=$(nmcli -g 802-11-wireless.powersave con show uuid "$uuid" 2>/dev/null); then
          continue
        fi
      fi
      if [[ -z $powersave || $powersave == 0* || $powersave == 3* || $powersave == "default" || $powersave == "enable" ]]; then
        iw dev "$iface" set power_save on 2>/dev/null || true
      fi
    done
  done
'
