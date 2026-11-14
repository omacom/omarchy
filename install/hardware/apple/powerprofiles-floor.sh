# Apple Silicon runs schedutil in every power profile (omarchy-power-profiles-
# daemon), and its energy-aware scheduler starts short-lived threads on the
# efficiency cores. A utilisation clamp floor on the users' processes moves
# that work to the performance cores while it runs, as on Snapdragon X. See
# bin/omarchy-powerprofiles-floor.

if omarchy-hw-aarch64-apple; then
  install -Dm644 "$OMARCHY_PATH/default/systemd/system/omarchy-powerprofiles-floor.service" \
    /etc/systemd/system/omarchy-powerprofiles-floor.service
  systemctl enable omarchy-powerprofiles-floor.service

  # As in install/hardware/qualcomm/powerprofiles-floor.sh: an image's first
  # boot queued its start jobs already, so start it there.
  if [[ ${OMARCHY_IMAGE_DEFERRED_HARDWARE:-} == "1" ]]; then
    systemctl start --no-block omarchy-powerprofiles-floor.service || true
  fi
fi
