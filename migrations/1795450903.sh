echo "Unload MediaTek MT7925 Bluetooth cleanly on shutdown or reboot"

# MediaTek MT7925 / AMD RZ717 combo cards can wedge their internal USB
# Bluetooth interface across warm reboots without a clean driver teardown.
if ! omarchy-hw-pci 14c3:7925 14c3:0717; then
  exit 0
fi

unit=/etc/systemd/system/omarchy-mt7925-bluetooth-shutdown.service

if [[ ! -e $unit ]]; then
  sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
    source "$OMARCHY_PATH/install/hardware/fix-mt7925-bluetooth.sh"
  '
  sudo systemctl daemon-reload
fi

if ! systemctl is-active --quiet omarchy-mt7925-bluetooth-shutdown.service; then
  sudo systemctl start omarchy-mt7925-bluetooth-shutdown.service
fi
