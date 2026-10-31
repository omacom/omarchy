# The Galaxy Book2 Pro 360 (950QED) ZNT clickpad exposes a companion Mouse
# alongside its real Touchpad. Suppress the extra input node at the libinput
# boundary, so every compositor gets the same fix without per-user overrides.
# Restrict the workaround to the tested Samsung model.
if grep -Fxq "SAMSUNG ELECTRONICS CO., LTD." /sys/class/dmi/id/sys_vendor 2>/dev/null &&
  omarchy-hw-match "^950QED$"; then
  sudo install -Dm644 "$OMARCHY_PATH/default/udev/samsung-950qed-clickpad.rules" /etc/udev/rules.d/61-znt-clickpad-mouse.rules || return

  # Image provisioning runs after coldplug but before the first login. Refresh
  # only the companion nodes now; active-session migrations request a reboot.
  if [[ ${OMARCHY_IMAGE_DEFERRED_HARDWARE:-} == "1" ]]; then
    sudo udevadm control --reload-rules || return
    for event in /sys/class/input/event*; do
      [[ -r $event/device/name && $(<"$event/device/name") == "ZNT0001:00 14E5:650E Mouse" ]] || continue
      sudo udevadm trigger --action=change "$event" || return
    done
    sudo udevadm settle || return
  fi
fi
