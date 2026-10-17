echo "Re-apply the power profile when an ASUS ROG laptop swaps chargers"

# The unit's ConditionPathExists keeps it inert on machines without ASUS
# charge_mode, so it is enabled everywhere, the same as at first run.
systemctl --user daemon-reload >/dev/null 2>&1 || true

# `systemctl enable` needs a live user manager, which an `omarchy update` from a
# TTY does not have; then write the symlink it would have written.
if ! systemctl --user enable omarchy-powerprofiles-source-monitor.service >/dev/null 2>&1; then
  wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn /usr/lib/systemd/user/omarchy-powerprofiles-source-monitor.service \
    "$wants_dir/omarchy-powerprofiles-source-monitor.service"
fi

if systemctl --user is-active --quiet graphical-session.target; then
  systemctl --user start omarchy-powerprofiles-source-monitor.service >/dev/null 2>&1 || true
fi
