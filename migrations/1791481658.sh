echo "Keep audio from jumping to the speakers when the displays blank"

conf="wireplumber/wireplumber.conf.d/hold-outputs-while-blanked.conf"

if [[ ! -f "$HOME/.config/$conf" ]]; then
  omarchy-refresh-config "$conf"
  # WirePlumber only reads conf.d at startup; restart it if it is running.
  systemctl --user try-restart wireplumber.service 2>/dev/null || true
fi
