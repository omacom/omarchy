echo "Enable GPD Pocket 4 screen rotation and boot orientation"

# install/hardware/gpd-pocket-4.sh only runs during ISO finalization. Existing
# Pocket 4 installs need the kernel cmdline, udev matrix, iio-sensor-proxy,
# and the user unit that tracks the accelerometer.

if omarchy-hw-gpd-pocket-4; then
  source "$OMARCHY_PATH/install/hardware/gpd-pocket-4.sh"

  unit=omarchy-gpd-pocket-4-rotate.service
  unit_source="$OMARCHY_PATH/default/systemd/user/$unit"
  packaged="/usr/lib/systemd/user/$unit"
  detector="$OMARCHY_PATH/bin/omarchy-hw-gpd-pocket-4"
  rotate="$OMARCHY_PATH/bin/omarchy-hw-gpd-pocket-4-rotate"

  as_root() {
    if (( EUID == 0 )); then
      "$@"
    else
      pkexec "$@"
    fi
  }

  # systemd and ExecStart=/usr/bin/... only see packaged paths. A linked
  # checkout (and any omarchy-settings that has not shipped this unit yet)
  # has to publish them once; pkexec so a GUI update can auth without a TTY.
  if [[ ! -f $packaged || ! -x /usr/bin/omarchy-hw-gpd-pocket-4 || ! -x /usr/bin/omarchy-hw-gpd-pocket-4-rotate ]]; then
    as_root /usr/bin/bash -c '
      set -euo pipefail
      if [[ -x "$1" ]]; then /usr/bin/install -Dm755 "$1" /usr/bin/omarchy-hw-gpd-pocket-4; fi
      if [[ -x "$2" ]]; then /usr/bin/install -Dm755 "$2" /usr/bin/omarchy-hw-gpd-pocket-4-rotate; fi
      if [[ -f "$3" ]]; then /usr/bin/install -Dm644 "$3" /usr/lib/systemd/user/omarchy-gpd-pocket-4-rotate.service; fi
    ' bash "$detector" "$rotate" "$unit_source"
  fi

  systemctl --user daemon-reload >/dev/null 2>&1 || true

  # `systemctl enable` needs a live user manager, which an update from a TTY
  # does not have, so fall back to writing the symlink it would have written.
  if ! systemctl --user enable "$unit" >/dev/null 2>&1; then
    wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
    mkdir -p "$wants_dir"
    ln -sfn "$packaged" "$wants_dir/$unit"
  fi

  if systemctl --user is-active --quiet graphical-session.target; then
    systemctl --user start "$unit" >/dev/null 2>&1 || true
  fi

  omarchy-state set reboot-required
fi
