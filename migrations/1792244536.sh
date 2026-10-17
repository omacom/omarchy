echo "Keep Bluetooth speaker auto-connect, but stop connecting headphones and phones"

conf="$HOME/.config/wireplumber/wireplumber.conf.d/bluetooth-a2dp-autoconnect.conf"
shipped="$OMARCHY_PATH/config/wireplumber/wireplumber.conf.d/bluetooth-a2dp-autoconnect.conf"

# The rule shipped unchanged from 3.x through 4.0.4, and an a2dp_sink-only form
# of it is in flight for #12642. Replace either with the current rule, which
# also leaves headphones, headsets, hands-free devices and phones alone
# (#15456). A copy that differs, or a symlink, is the user's own and stays.
if [[ -f $conf && ! -L $conf ]]; then
  body=$(sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' -- "$conf")

  shipped_two='monitor.bluez.rules = [
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
]'

  shipped_sink='monitor.bluez.rules = [
  {
    matches = [
      {
        device.name = "~bluez_card.*"
      }
    ]
    actions = {
      update-props = {
        bluez5.auto-connect = [ a2dp_sink ]
      }
    }
  }
]'

  if [[ $body == "$shipped_two" || $body == "$shipped_sink" ]]; then
    cp -f -- "$shipped" "$conf"
    # WirePlumber only reads conf.d at startup; restart it if it is running.
    systemctl --user try-restart wireplumber.service 2>/dev/null || true
  fi
fi
