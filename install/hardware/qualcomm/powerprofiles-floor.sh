# Snapdragon X runs schedutil in every power profile, which ramps too slowly
# for bursty work; a utilisation clamp floor on the users' processes makes up
# for it. See bin/omarchy-powerprofiles-floor.

if omarchy-hw-aarch64-qualcomm; then
  install -Dm644 "$OMARCHY_PATH/default/systemd/system/omarchy-powerprofiles-floor.service" \
    /etc/systemd/system/omarchy-powerprofiles-floor.service
  systemctl enable omarchy-powerprofiles-floor.service

  # An image's first boot runs this after the boot's start jobs are queued, so
  # the newly enabled service would wait for the next boot. Only there, as in
  # install/hardware/bluetooth.sh.
  if [[ ${OMARCHY_IMAGE_DEFERRED_HARDWARE:-} == "1" ]]; then
    systemctl start --no-block omarchy-powerprofiles-floor.service || true
  fi
fi
