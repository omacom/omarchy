echo "Unload MediaTek MT7925 Bluetooth cleanly on shutdown or reboot"

# MediaTek MT7925 / AMD RZ717 combo cards can wedge their internal USB
# Bluetooth interface across warm reboots without a clean driver teardown.
if ! omarchy-hw-pci 14c3:7925 14c3:0717; then
  exit 0
fi

service=omarchy-mt7925-bluetooth-shutdown.service
source_unit="$OMARCHY_PATH/default/systemd/system/$service"
unit="/etc/systemd/system/$service"

if [[ ! -e $unit ]]; then
  if [[ ! -f $source_unit ]]; then
    echo "Waiting for $source_unit to arrive before enabling $service"
    exit 75
  fi

  sudo install -Dm644 "$source_unit" "$unit"
  sudo systemctl daemon-reload
fi

if ! systemctl is-enabled --quiet "$service"; then
  sudo systemctl enable "$service"
fi

if ! systemctl is-active --quiet "$service"; then
  sudo systemctl start "$service"
fi
