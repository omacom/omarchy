echo "Replace udiskie with automountd for automounting removable drives"

omarchy-pkg-add automountd

systemctl --user daemon-reload >/dev/null 2>&1 || true

# `systemctl enable` needs a live user manager, which an update from a TTY does
# not have, so fall back to writing the symlink it would have written.
if ! systemctl --user enable automountd.service >/dev/null 2>&1; then
  wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn /usr/lib/systemd/user/automountd.service "$wants_dir/automountd.service"
fi

# The running session started udiskie from the old autostart. Stop it before
# automountd starts, so the two never race to mount the same drive.
pkill -x udiskie || true

# Nothing to start into over SSH; the next graphical login handles it.
if systemctl --user is-active --quiet graphical-session.target; then
  systemctl --user start automountd.service >/dev/null 2>&1 || true
fi

omarchy-pkg-drop udiskie
