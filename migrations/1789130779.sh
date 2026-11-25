echo "Keep the KEF LSX II LT USB sink from suspending"

conf="wireplumber/wireplumber.conf.d/kef-lsx-no-suspend.conf"

if [[ ! -f "$HOME/.config/$conf" ]]; then
  omarchy-refresh-config "$conf"
  # WirePlumber only reads conf.d at startup; restart it if it is running.
  systemctl --user try-restart wireplumber.service 2>/dev/null || true
fi
