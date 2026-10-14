systemctl enable bluetooth.service

# An image's first boot runs this after the adapter has brought up (or queued)
# bluetooth.target, and a target never starts a unit enabled after its start
# job was made, so Bluetooth would stay off until the next boot. Only there
# (omarchy-provision-hardware sets the marker): an install or a rerun of
# hardware setup leaves the service as it finds it. Without Bluetooth support
# the unit's own condition skips it.
if [[ ${OMARCHY_IMAGE_DEFERRED_HARDWARE:-} == "1" ]]; then
  systemctl start --no-block bluetooth.service || true
fi

# AutoEnable stays at its stock default on purpose. It was set to false here to
# persist the power state, which it never did: BlueZ has no such behaviour, so
# all it bought was Bluetooth coming up off on every boot. omarchy-bluetooth-power
# holds the state in the rfkill soft block instead, and leaving AutoEnable alone
# is what lets bluetoothd bring the adapter back up when that block is lifted.
