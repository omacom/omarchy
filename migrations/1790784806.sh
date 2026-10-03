echo "Remember Bluetooth power without blocking application power-on"

state_file="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/bluetooth-power"

# Old Omarchy off and an external airplane-mode block are indistinguishable.
# Preserve every existing block; only an explicit Omarchy on may clear it.
# Capture off through the helper's atomic write even if BlueZ is unavailable,
# but do not let a blocked secondary radio turn off a powered primary at login.
if [[ ! -e $state_file ]]; then
  if rfkill --raw --noheadings --output SOFT list bluetooth | grep -qx blocked; then
    if omarchy-bluetooth-power is-on; then
      omarchy-bluetooth-power save
    else
      omarchy-bluetooth-power save off
    fi
    echo "Existing Bluetooth blocks are preserved. Enable Bluetooth once in Omarchy to allow application power-on."
  else
    omarchy-bluetooth-power save
  fi
fi

# Enable restoration for the next login. Adopt an already running session with
# a transient snapshot-only monitor: never apply old preferences over a live
# connection, and do not leave subsequent application changes unsaved either.
if systemctl --user daemon-reload && systemctl --user enable omarchy-bluetooth-power.service; then
  if systemctl --user is-active --quiet graphical-session.target &&
    ! systemctl --user is-active --quiet omarchy-bluetooth-power.service &&
    ! systemctl --user is-active --quiet omarchy-bluetooth-power-adopt.service; then
    systemd-run --user --collect --unit=omarchy-bluetooth-power-adopt.service \
      --property=After=graphical-session.target \
      --property=PartOf=graphical-session.target \
      --property=Restart=on-failure \
      /usr/bin/omarchy-bluetooth-power monitor --adopt
  fi
else
  wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn /usr/lib/systemd/user/omarchy-bluetooth-power.service "$wants_dir/omarchy-bluetooth-power.service"
fi
