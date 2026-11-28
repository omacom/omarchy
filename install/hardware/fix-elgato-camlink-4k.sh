# Expose the Elgato Cam Link 4K as a 16:9-only virtual camera.
# Browsers ask it for 640x480, which it fills by cropping, and the 4:3 frame
# then gets stretched into a 16:9 tile. The raw node is hidden from users and
# v4l2-relayd re-exposes it at 1280x720 under the same name.

if omarchy-hw-elgato-camlink-4k; then
  _camlink_sole_linux_omarchy() {
    local found=0 pkgbase
    omarchy-pkg-present linux-omarchy || return 1
    for pkgbase in /usr/lib/modules/*/pkgbase; do
      [[ -f $pkgbase ]] || continue
      [[ $(<"$pkgbase") == "linux-omarchy" ]] || return 1
      found=1
    done
    (( found ))
  }

  if _camlink_sole_linux_omarchy && ! omarchy-pkg-present v4l2loopback-dkms; then
    v4l2_pkg=linux-omarchy-v4l2loopback
  else
    v4l2_pkg=v4l2loopback-dkms
  fi

  omarchy-pkg-add "$v4l2_pkg" v4l2loopback-utils v4l2-relayd

  sudo install -Dm644 "$OMARCHY_PATH/default/udev/elgato-camlink-4k.rules" /etc/udev/rules.d/71-elgato-camlink-4k.rules
  sudo install -Dm644 "$OMARCHY_PATH/default/v4l2-relayd/camlink.conf" /etc/v4l2-relayd.d/camlink.conf
  sudo install -Dm644 "$OMARCHY_PATH/default/systemd/system/camlink-4k-loopback.service" /etc/systemd/system/camlink-4k-loopback.service
  sudo install -Dm644 "$OMARCHY_PATH/default/systemd/system/v4l2-relayd@camlink.service.d/camlink.conf" "/etc/systemd/system/v4l2-relayd@camlink.service.d/camlink.conf"

  # The module's own default device would otherwise show up in browsers as
  # "Dummy video device" on machines without another relay.
  echo "options v4l2loopback exclusive_caps=1" | sudo tee /etc/modprobe.d/v4l2loopback-exclusive-caps.conf >/dev/null
fi
