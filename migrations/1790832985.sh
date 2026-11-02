echo "Keep tray icons across shell restarts with a persistent StatusNotifierWatcher"

# install/user/first-run enables the watcher only on new installs.

systemctl --user daemon-reload >/dev/null 2>&1 || true

# `systemctl enable` needs a live user manager, which an update from a TTY does
# not have, so fall back to writing the symlink it would have written.
if ! systemctl --user enable omarchy-sni-watcher.service >/dev/null 2>&1; then
  wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn /usr/lib/systemd/user/omarchy-sni-watcher.service \
    "$wants_dir/omarchy-sni-watcher.service"
fi

# The running shell holds the watcher name, so this one waits in the queue and
# takes over when omarchy update restarts the shell.
if systemctl --user is-active --quiet graphical-session.target; then
  systemctl --user start omarchy-sni-watcher.service >/dev/null 2>&1 || true
fi
