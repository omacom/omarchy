echo "Stop auto-connecting Bluetooth phones as an A2DP audio source"

conf="$HOME/.config/wireplumber/wireplumber.conf.d/bluetooth-a2dp-autoconnect.conf"

# The rule shipped unchanged from 3.x through 4.0.4; a copy that differs, or a symlink, is the user's own.
if [[ -f $conf && ! -L $conf && $(sha256sum <"$conf") == "825aa71689d2157980344283a76f34b5079d366a4dc359f7c151077e166a5631  -" ]]; then
  cp -f "$OMARCHY_PATH/config/wireplumber/wireplumber.conf.d/bluetooth-a2dp-autoconnect.conf" "$conf"
  # WirePlumber only reads conf.d at startup; restart it if it is running.
  systemctl --user try-restart wireplumber.service 2>/dev/null || true
fi
