# Intel Macs with Broadcom Bluetooth on a UART run it without patch firmware,
# and BlueZ then never reconnects a mouse or keyboard that drops. See
# bin/omarchy-bluetooth-hid-reconnect.

if omarchy-hw-apple-uart-bluetooth; then
  install -Dm644 "$OMARCHY_PATH/default/systemd/system/omarchy-bluetooth-hid-reconnect.service" \
    /etc/systemd/system/omarchy-bluetooth-hid-reconnect.service
  systemctl enable omarchy-bluetooth-hid-reconnect.service

  # An image's first boot runs this after the boot's start jobs are queued, so
  # the newly enabled service would wait for the next boot. Only there, as in
  # install/hardware/bluetooth.sh.
  if [[ ${OMARCHY_IMAGE_DEFERRED_HARDWARE:-} == "1" ]]; then
    systemctl start --no-block omarchy-bluetooth-hid-reconnect.service || true
  fi
fi
