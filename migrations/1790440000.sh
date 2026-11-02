echo "Enable the D-Bus idle-inhibit daemon so apps can suppress the screensaver"

# Own org.freedesktop.ScreenSaver so Chromium, Firefox/Zen, and VLC can keep
# the screensaver off during playback (#6475).

user_config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
unit_source="$OMARCHY_PATH/default/systemd/user/omarchy-idle-inhibit.service"
unit_dest="$user_config_home/systemd/user/omarchy-idle-inhibit.service"
unit_target="/usr/lib/systemd/user/omarchy-idle-inhibit.service"

if [[ ! -f $unit_target ]]; then
  unit_target=$unit_dest
  if [[ -f $unit_source ]]; then
    mkdir -p "$(dirname "$unit_dest")"
    ln -sfn "$unit_source" "$unit_dest"
  fi
fi

systemctl --user daemon-reload >/dev/null 2>&1 || true

if ! systemctl --user enable omarchy-idle-inhibit.service >/dev/null 2>&1; then
  wants_dir="$user_config_home/systemd/user/graphical-session.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn "$unit_target" "$wants_dir/omarchy-idle-inhibit.service"
fi

if systemctl --user is-active --quiet graphical-session.target; then
  systemctl --user start omarchy-idle-inhibit.service >/dev/null 2>&1 || true
fi
