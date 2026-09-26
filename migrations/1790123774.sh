echo "Keep speakersafetyd restarting after a 96 kHz panic, and toast if the amps stay locked"

drop_in_source="$OMARCHY_PATH/default/systemd/system/speakersafetyd.service.d/10-omarchy.conf"
drop_in_dest=/etc/systemd/system/speakersafetyd.service.d/10-omarchy.conf
watch_unit="$OMARCHY_PATH/default/systemd/user/omarchy-speakersafetyd-watch.service"

if [[ -f /usr/lib/systemd/system/speakersafetyd.service && -f $drop_in_source ]]; then
  if ! cmp -s "$drop_in_source" "$drop_in_dest" 2>/dev/null; then
    sudo install -Dm644 "$drop_in_source" "$drop_in_dest"
    sudo systemctl daemon-reload >/dev/null 2>&1 || true
  fi

  # Existing installs may already be sitting in start-limit-hit with the amps
  # locked. The new policy only applies on the next start.
  if systemctl is-failed --quiet speakersafetyd 2>/dev/null; then
    sudo systemctl reset-failed speakersafetyd >/dev/null 2>&1 || true
    sudo systemctl start speakersafetyd >/dev/null 2>&1 || true
  fi
fi

systemctl --user daemon-reload >/dev/null 2>&1 || true

if [[ -f $watch_unit ]]; then
  if ! systemctl --user enable "$watch_unit" >/dev/null 2>&1; then
    wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
    mkdir -p "$wants_dir"
    ln -sfn "$watch_unit" "$wants_dir/omarchy-speakersafetyd-watch.service"
  fi

  if systemctl --user is-active --quiet graphical-session.target; then
    systemctl --user start omarchy-speakersafetyd-watch.service >/dev/null 2>&1 ||
      systemctl --user start "$watch_unit" >/dev/null 2>&1 || true
  fi
fi
