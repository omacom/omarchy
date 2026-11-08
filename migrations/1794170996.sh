echo "Unload BCM4377 Wi-Fi before sleep on Macs that have that chip"

# install/hardware/apple/fix-bcm4377-sleep.sh covers a new install. This
# reaches a machine that was installed before that leaf existed. It does not
# pick a sleep mode, and it does not reload Wi-Fi while the user is online.
# An administrator's copy of the unit is left in place.

omarchy-hw-aarch64-apple && exit 0

if ! lspci -nn | grep '14e4:4488' >/dev/null; then
  exit 0
fi

unit_name=omarchy-wifi-bcm4377-sleep.service
unit_src="$OMARCHY_PATH/default/systemd/system/$unit_name"
unit_dst="${OMARCHY_WIFI_BCM4377_UNIT_DST:-/etc/systemd/system/$unit_name}"

if [[ ! -f $unit_src ]]; then
  echo "Missing $unit_src" >&2
  exit 1
fi

if [[ ! -e $unit_dst ]]; then
  sudo install -Dm644 "$unit_src" "$unit_dst"
  sudo systemctl daemon-reload
fi

# The second user on the machine hits this too. Enable is a no-op once the
# sleep.target requirement is already installed, so a later account does not
# prompt for a password when the first one finished the repair.
if ! systemctl is-enabled --quiet "$unit_name"; then
  sudo systemctl enable "$unit_name"
fi
