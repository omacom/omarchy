echo "Enable the audio playback idle inhibitor on existing installs"

# omarchy-audio-inhibit.service is enabled by first-run setup only, so systems
# installed before the unit shipped never got it. Migrations run per-user after
# pacman finishes, so the unit file is already in place here; enable it for
# this user's session.
if [[ ! -f /usr/lib/systemd/user/omarchy-audio-inhibit.service && -f ${OMARCHY_PATH:-}/default/systemd/user/omarchy-audio-inhibit.service ]]; then
  mkdir -p "$HOME/.config/systemd/user"
  cp "$OMARCHY_PATH/default/systemd/user/omarchy-audio-inhibit.service" "$HOME/.config/systemd/user/"
fi

systemctl --user daemon-reload >/dev/null 2>&1 || true

if ! systemctl --user enable omarchy-audio-inhibit.service >/dev/null 2>&1; then
  wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
  mkdir -p "$wants_dir"
  unit_target="/usr/lib/systemd/user/omarchy-audio-inhibit.service"
  if [[ ! -f $unit_target && -f $HOME/.config/systemd/user/omarchy-audio-inhibit.service ]]; then
    unit_target="../omarchy-audio-inhibit.service"
  fi
  ln -sfn "$unit_target" "$wants_dir/omarchy-audio-inhibit.service"
fi

if systemctl --user is-active --quiet graphical-session.target; then
  systemctl --user start omarchy-audio-inhibit.service >/dev/null 2>&1 || true
fi
