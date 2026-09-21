echo "Drop a2dp_source from Bluetooth auto-connect profiles"

conf="wireplumber/wireplumber.conf.d/bluetooth-a2dp-autoconnect.conf"
user_conf="$HOME/.config/$conf"

if [[ -f $user_conf ]] && grep -q "a2dp_source" "$user_conf"; then
  omarchy-refresh-config "$conf"
  # WirePlumber only reads conf.d at startup; restart it if it is running.
  systemctl --user try-restart wireplumber.service 2>/dev/null || true
fi
