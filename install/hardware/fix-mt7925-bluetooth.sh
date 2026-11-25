# MediaTek MT7925 / AMD RZ717 Wi-Fi 7 + Bluetooth combo cards can latch up
# their internal USB Bluetooth interface across warm reboots (descriptor read
# error -110, address error -62), leaving Bluetooth missing until a full EC
# power drain. Unloading btusb and btmtk on shutdown runs btmtk_usb_shutdown()
# so the adapter enumerates cleanly on the next boot.

if omarchy-hw-pci 14c3:7925 14c3:0717; then
  install -Dm644 "$OMARCHY_PATH/default/systemd/system/omarchy-mt7925-bluetooth-shutdown.service" \
    /etc/systemd/system/omarchy-mt7925-bluetooth-shutdown.service
  systemctl enable omarchy-mt7925-bluetooth-shutdown.service

  # An image's first boot runs this after the boot's start jobs are queued, so
  # arm the shutdown hook now rather than waiting for a second boot.
  if [[ ${OMARCHY_IMAGE_DEFERRED_HARDWARE:-} == "1" ]]; then
    systemctl start --no-block omarchy-mt7925-bluetooth-shutdown.service || true
  fi
fi
