echo "Disable Bluetooth hardware volume so saved volume is restored on connect"

conf="wireplumber/wireplumber.conf.d/51-bt-volume.conf"

if [[ ! -f "$HOME/.config/$conf" ]]; then
  omarchy-refresh-config "$conf"
  # WirePlumber only reads conf.d at startup; restart it if it is running.
  systemctl --user try-restart wireplumber.service 2>/dev/null || true
fi