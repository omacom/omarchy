echo "Cap MacBook10,1 package power at 4.5W/7W and CPU turbo at 3GHz"

unit_path=${OMARCHY_MACBOOK10_ENVELOPE_UNIT:-/etc/systemd/system/omarchy-macbook10-power-envelope.service}
sleep_hook=${OMARCHY_MACBOOK10_ENVELOPE_SLEEP_HOOK:-/usr/lib/systemd/system-sleep/omarchy-macbook10-power-envelope}

# Migrations run once per user; setup makes the resume hook executable last, so finding it means another user finished.
if omarchy-hw-macbook10 && ! [[ -f $unit_path && -x $sleep_hook ]]; then
  source "$OMARCHY_PATH/install/hardware/apple/fix-macbook10-power-envelope.sh"
  sudo /usr/bin/omarchy-hw-macbook10-power-envelope
fi
