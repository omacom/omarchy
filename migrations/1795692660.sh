echo "Update the bar clock as soon as the time or timezone changes"

# The bar clock moves only on its next whole-minute tick, so after a resume, a
# stepped clock or a new timezone it showed the old time for up to a minute.
# omarchy-clock-resync.timer asks the shell to catch up on each of those. New
# installs enable it at first run; this enables it on existing ones.

timer=omarchy-clock-resync.timer

# omarchy-settings ships the timer and its service. A dev checkout can run ahead
# of that package, so wait for it rather than enable units that are not there.
for unit in omarchy-clock-resync.service "$timer"; do
  if [[ ! -f /usr/lib/systemd/user/$unit ]]; then
    echo "Waiting for the omarchy-settings package that ships $unit" >&2
    exit 75
  fi
done

systemctl --user daemon-reload >/dev/null 2>&1 || true

# `systemctl enable` needs a live user manager, which an update from a TTY does
# not always have, so fall back to writing the symlink it would have written.
if ! systemctl --user enable "$timer" >/dev/null 2>&1; then
  wants_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/graphical-session.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn "/usr/lib/systemd/user/$timer" "$wants_dir/$timer"
fi

# Outside a graphical session there is nothing to start into: the timer is
# PartOf graphical-session.target, and the next graphical login starts it. A
# failed start costs only the catch-up, so it is reported and left to that
# login rather than failing every later update.
if systemctl --user is-active --quiet graphical-session.target 2>/dev/null; then
  if ! error=$(systemctl --user start "$timer" 2>&1); then
    echo "Could not start $timer: $error"
    echo "The bar clock catches up on its next minute until the next login."
  fi
fi
