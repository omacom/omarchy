echo "Enable the Bluetooth MPRIS proxy so headset transport controls reach the player"

# Only first-run enables the units we ship, so existing installs never picked
# this one up. The drop-in keeps it inert where there is no bluetooth, so it is
# safe to enable unconditionally here.

systemctl --user daemon-reload >/dev/null 2>&1 || true

# `systemctl enable` needs a live user manager, which an update from a TTY does
# not have, so fall back to writing the symlink it would have written. The unit
# bluez ships is WantedBy=default.target, not graphical-session.target.
if ! systemctl --user enable mpris-proxy.service >/dev/null 2>&1; then
  wants_dir="$HOME/.config/systemd/user/default.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn /usr/lib/systemd/user/mpris-proxy.service \
    "$wants_dir/mpris-proxy.service"
fi

# Nothing to start into over SSH; the next login handles it. A failed start
# only delays headset button support, so it stays quiet.
if systemctl --user is-active --quiet default.target; then
  systemctl --user start mpris-proxy.service >/dev/null 2>&1 || true
fi
