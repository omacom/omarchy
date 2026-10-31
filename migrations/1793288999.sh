echo "Catch the bar clock up when the system clock jumps"

# SystemClock waits out the rest of the minute on a timer that stops during
# suspend, so after a wake the bar kept the old time for up to a minute. The
# timer restarts the clock when the system clock jumps, which a wake is. New
# installs enable it with the other user units; this is for existing ones.

# The units live in default/, so link them where the user manager looks. A
# link follows the shipped file, so it never goes stale.
mkdir -p "$HOME/.config/systemd/user"
for unit in omarchy-clock-resync.service omarchy-clock-resync.timer; do
  if [[ ! -e /usr/lib/systemd/user/$unit ]]; then
    ln -sfn "$OMARCHY_PATH/default/systemd/user/$unit" "$HOME/.config/systemd/user/$unit"
  fi
done

systemctl --user daemon-reload >/dev/null 2>&1 || true

# `systemctl enable` needs a live user manager, which an update from a TTY does
# not have, so fall back to writing the symlink it would have written.
if ! systemctl --user enable omarchy-clock-resync.timer >/dev/null 2>&1; then
  wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
  mkdir -p "$wants_dir"
  if [[ -e /usr/lib/systemd/user/omarchy-clock-resync.timer ]]; then
    ln -sfn /usr/lib/systemd/user/omarchy-clock-resync.timer "$wants_dir/omarchy-clock-resync.timer"
  else
    ln -sfn "$HOME/.config/systemd/user/omarchy-clock-resync.timer" "$wants_dir/omarchy-clock-resync.timer"
  fi
fi

# Nothing to start into over SSH; the next graphical login handles it.
if systemctl --user is-active --quiet graphical-session.target; then
  systemctl --user start omarchy-clock-resync.timer >/dev/null 2>&1 || true
fi
