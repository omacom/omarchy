echo "Fix Khadas Mind Graphics Speaker volume mapping"

conf="wireplumber/wireplumber.conf.d/khadas-mind-graphics-speaker.conf"

if [[ ! -f "$HOME/.config/$conf" ]]; then
  omarchy-refresh-config "$conf"
  # WirePlumber only reads conf.d at startup; restart it if it is running.
  systemctl --user try-restart wireplumber.service 2>/dev/null || true
fi
