echo "Drop a2dp_source from the stock Bluetooth auto-connect config"

conf="wireplumber/wireplumber.conf.d/bluetooth-a2dp-autoconnect.conf"
user_conf="$HOME/.config/$conf"
restart_pending="$HOME/.local/state/omarchy/wireplumber-a2dp-restart-pending"

# Only replace the config Omarchy shipped; preserve administrator changes.
if [[ -f $user_conf ]] && cmp -s "$user_conf" <(cat <<'CONF'
## Auto-connect A2DP playback/capture profiles on Bluetooth devices.
## This helps speakers and receivers expose their audio profiles without
## requiring manual PipeWire/WirePlumber recovery.

monitor.bluez.rules = [
  {
    matches = [
      {
        device.name = "~bluez_card.*"
      }
    ]
    actions = {
      update-props = {
        bluez5.auto-connect = [ a2dp_sink a2dp_source ]
      }
    }
  }
]
CONF
); then
  if systemctl --user is-active --quiet wireplumber.service; then
    mkdir -p "$(dirname "$restart_pending")"
    touch "$restart_pending"
  fi
  omarchy-refresh-config "$conf"
fi

# Retain the marker on failure, even if the failed restart left it inactive.
if [[ -f $restart_pending ]]; then
  systemctl --user restart wireplumber.service
  rm "$restart_pending"
fi
