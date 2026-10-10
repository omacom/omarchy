echo "Remove Omarchy USB and Thunderbolt device authorization"

usb=0
usb_unit=$HOME/.config/systemd/user/omarchy-usb-authorization.service
usb_state=$HOME/.local/state/omarchy/usb-authorization
if [[ -e $usb_unit || -L $usb_unit || -d $usb_state ]]; then
  usb=1
fi

sudo /bin/bash -p "$OMARCHY_PATH/migrations/retired-device-authorization/rollback.sh" rollback "$usb"

for unit in omarchy-usb-authorization.service omarchy-thunderbolt-authorization.service; do
  load_state=$(systemctl --user show -p LoadState --value "$unit")
  if [[ $load_state != "not-found" ]]; then
    systemctl --user disable --now "$unit"
  fi
  if systemctl --user is-active --quiet "$unit" || systemctl --user is-enabled --quiet "$unit"; then
    echo "$unit is still active or enabled; migration will retry." >&2
    exit 1
  fi
  path=$HOME/.config/systemd/user/$unit
  if [[ -e $path || -L $path ]]; then
    mv -- "$path" "$path.retired"
  fi
done
systemctl --user daemon-reload

echo "Installed accessory protection removed. Saved USB policy and Bolt keys are retained."
