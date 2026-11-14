# Install MIPI camera support for Intel IPU6 hardware

if omarchy-hw-intel-ipu6; then
  # The ov08x40 sensor (OVTI08F4) also sits behind IPU6 on Meteor Lake, and the
  # IPU7 leaf's sensor-only gate installs intel-ipu7-camera there. That stack
  # can't drive an IPU6 (#7697), and it disables WirePlumber's libcamera monitor
  # and blacklists ov08x40, so libcamera never gets a camera while it's present.
  # A plain -R keeps the GStreamer plugins and libraries it pulled in: other
  # packages use them optionally, and -Rns would take them along.
  if omarchy-pkg-present intel-ipu7-camera; then
    sudo pacman -R --noconfirm intel-ipu7-camera
    # The blacklist and the WirePlumber profile only lift on a fresh boot.
    omarchy-state set reboot-required
  fi

  # The package's scriptlet copies its sleep hook in, unowned, and older
  # releases left it behind on removal, restarting IPU7 relay units on every
  # resume. Only that exact hook is removed: unowned and naming the IPU7 relay.
  sleep_hook="${OMARCHY_SYSTEM_SLEEP_PATH:-/usr/lib/systemd/system-sleep}/camera-sleep-hook"
  if [[ -f $sleep_hook ]] && ! pacman -Qo "$sleep_hook" &>/dev/null &&
    grep -q 'v4l2-relayd@ipu7' "$sleep_hook"; then
    sudo rm -f "$sleep_hook"
  fi

  # The ISYS driver only exposes raw Bayer capture queues, which nothing can
  # use as a webcam. libcamera composes them into one camera and its software
  # ISP debayers it; pipewire-libcamera is what puts that in front of apps.
  omarchy-pkg-add libcamera pipewire-libcamera gst-plugin-libcamera
fi
