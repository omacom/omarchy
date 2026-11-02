# Firmware scan 0x7e is labelled emoji but defaults to KEY_BLUETOOTH.
# A compositor binding alone cannot stop the kernel rfkill input handler.
# Tested product_name: ASUS Vivobook S 16 M5606UA_M5606UA
if [[ $(cat /sys/class/dmi/id/sys_vendor 2>/dev/null) == "ASUSTeK COMPUTER INC." ]] &&
   omarchy-hw-match '^ASUS Vivobook S 16 M5606UA_M5606UA$'; then
  source_hwdb="$OMARCHY_PATH/default/udev/asus-vivobook-m5606-keyboard.hwdb"
  target_hwdb="/etc/udev/hwdb.d/90-asus-vivobook-m5606-keyboard.hwdb"
  if ! cmp -s "$source_hwdb" "$target_hwdb"; then
    sudo install -Dm644 "$source_hwdb" "$target_hwdb"
    sudo systemd-hwdb update
    for event in /sys/class/input/event*; do
      if [[ $(cat "$event/device/name" 2>/dev/null) == "Asus WMI hotkeys" ]]; then
        sudo udevadm trigger --action=change "$event" 2>/dev/null || true
      fi
    done
    sudo udevadm settle 2>/dev/null || true
  fi
fi
