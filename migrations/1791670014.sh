echo "Remove Omarchy USB and Thunderbolt device authorization"

source "$OMARCHY_PATH/migrations/retired-device-authorization/units.sh"

usb=0
usb_unit=$HOME/.config/systemd/user/omarchy-usb-authorization.service
usb_state=$HOME/.local/state/omarchy/usb-authorization
if [[ -f $usb_state/policy-generated-by-omarchy ]]; then
  usb=1
fi

complete=/var/lib/omarchy/retired-device-authorization/completed
pending=$HOME/.local/state/omarchy/device-authorization-rollback-pending
status=0
if [[ ! -f $complete || -L $complete || $(stat -c '%u:%a' "$complete") != "0:644" ]]; then
  if [[ -f $pending || -e $usb_unit || -L $usb_unit || -d $usb_state ||
    -d /var/lib/omarchy/thunderbolt-authorization ||
    -f /etc/omarchy/thunderbolt-authorization.enabled || -f /etc/omarchy/thunderbolt-authorization.pending ||
    -f /etc/limine-entry-tool.d/usb-authorization.conf ||
    -d /var/lib/omarchy/retired-device-authorization ||
    -f /usr/share/polkit-1/actions/org.omarchy.usb.policy || -f /usr/share/polkit-1/actions/org.omarchy.thunderbolt.policy ]] ||
    grep -Fq '# Omarchy USB authorization begin' /etc/default/limine 2>/dev/null; then
    mkdir -p "${pending%/*}"
    touch "$pending"
    if sudo /bin/bash -p /usr/share/omarchy/migrations/retired-device-authorization/rollback.sh rollback "$usb"; then
      rm -- "$pending"
    else
      # Boot or firmware recovery can leave protection enabled. Keep the
      # packaged approval path and its existing watchers usable until retry.
      echo "Accessory rollback is incomplete; approval remains available. Run omarchy-migrate to retry."
      exit 1
    fi
  fi
else
  rm -f -- "$pending"
fi

for unit in omarchy-usb-authorization.service omarchy-thunderbolt-authorization.service; do
  if ! da_stop_unit "$unit" user; then
    status=1
    continue
  fi
  path=$HOME/.config/systemd/user/$unit
  if [[ -e $path || -L $path ]]; then
    da_archive "$path" || status=1
  fi
done
systemctl --user daemon-reload || status=1

if (( status != 0 )); then
  echo "Accessory rollback is incomplete; this migration will retry."
  exit 1
fi

echo "Installed accessory protection removed. Saved USB policy and Bolt keys are retained."
