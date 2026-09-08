echo "Enable GPD Pocket 4 screen rotation and boot orientation"

# install/hardware/gpd-pocket-4.sh only runs during ISO finalization. Existing
# Pocket 4 installs need the kernel cmdline, udev matrix, iio-sensor-proxy,
# and the user unit that tracks the accelerometer.

if omarchy-hw-gpd-pocket-4; then
  source "$OMARCHY_PATH/install/hardware/gpd-pocket-4.sh"

  unit=omarchy-gpd-pocket-4-rotate.service
  unit_source="$OMARCHY_PATH/default/systemd/user/$unit"
  packaged="/usr/lib/systemd/user/$unit"
  user_unit="$HOME/.config/systemd/user/$unit"

  # systemd does not search $OMARCHY_PATH. A linked checkout, and any
  # omarchy-settings package that has not yet shipped this unit, need it
  # on a unit path before enable can succeed.
  if [[ ! -f $packaged && -f $unit_source ]]; then
    mkdir -p "$HOME/.config/systemd/user"
    ln -sfn "$unit_source" "$user_unit"
  fi

  systemctl --user daemon-reload >/dev/null 2>&1 || true

  # `systemctl enable` needs a live user manager, which an update from a TTY
  # does not have, so fall back to writing the symlink it would have written.
  if ! systemctl --user enable "$unit" >/dev/null 2>&1; then
    wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
    mkdir -p "$wants_dir"
    if [[ -f $packaged ]]; then
      ln -sfn "$packaged" "$wants_dir/$unit"
    elif [[ -e $user_unit ]]; then
      ln -sfn "../$unit" "$wants_dir/$unit"
    elif [[ -f $unit_source ]]; then
      ln -sfn "$unit_source" "$wants_dir/$unit"
    fi
  fi

  if systemctl --user is-active --quiet graphical-session.target; then
    systemctl --user start "$unit" >/dev/null 2>&1 || true
  fi

  omarchy-state set reboot-required
fi
