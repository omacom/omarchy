echo "Enable the D-Bus idle-inhibit daemon so apps can suppress the screensaver"

# Own org.freedesktop.ScreenSaver so Chromium, Firefox/Zen, and VLC can keep
# the screensaver off during playback (#6475), and so desktop apps such as
# 1Password hear when the session locks.

systemctl --user daemon-reload >/dev/null 2>&1 || true

# `systemctl enable` needs a live user manager, which an update from a TTY does
# not have, so fall back to writing the symlink it would have written.
if ! systemctl --user enable omarchy-idle-inhibit.service >/dev/null 2>&1; then
  wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn /usr/lib/systemd/user/omarchy-idle-inhibit.service \
    "$wants_dir/omarchy-idle-inhibit.service"
fi

# Nothing to start into over SSH; the next graphical login handles it.
if systemctl --user is-active --quiet graphical-session.target; then
  systemctl --user start omarchy-idle-inhibit.service >/dev/null 2>&1 || true
fi
