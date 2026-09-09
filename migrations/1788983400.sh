echo "Warn when an app takes a camera over V4L2 and locks everyone else out"

# A V4L2 camera streams to one process at a time, and the app that lost out
# only says "no camera". The watcher names whoever holds it, so that stops
# looking like broken hardware. Fresh installs enable the unit from
# install/user/first-run, which is skipped after the first login, so existing
# installs need it done here.

systemctl --user daemon-reload >/dev/null 2>&1 || true

# `systemctl enable` needs a live user manager, which an update from a TTY does
# not have, so fall back to writing the symlink it would have written.
if ! systemctl --user enable omarchy-camera-watch.service >/dev/null 2>&1; then
  wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn /usr/lib/systemd/user/omarchy-camera-watch.service \
    "$wants_dir/omarchy-camera-watch.service"
fi

# Nothing to start into over SSH; the next graphical login handles it.
if systemctl --user is-active --quiet graphical-session.target; then
  systemctl --user start omarchy-camera-watch.service >/dev/null 2>&1 || true
fi
