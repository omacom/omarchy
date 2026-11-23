echo "Replace a desktop portal that started before the display existed"

# omarchy-settings ships the drop-in. A portal already running from earlier in
# this login still has the empty environment it started with, and daemon-reload
# alone does not replace it. The unit's KillMode=control-group also stops every
# app that portal launched, so restart only a process whose own environment is
# missing WAYLAND_DISPLAY or QT_QPA_PLATFORM. Leave one that already has both,
# one whose environment cannot be read, and a manager with no display, such as
# an update over SSH.
systemctl --user daemon-reload >/dev/null 2>&1 || true

if systemctl --user is-active --quiet graphical-session.target; then
  # Capture first. Piping this into grep -q returns 141 under pipefail once
  # the manager environment is long enough for grep to close the pipe, and
  # the repair is then skipped while this migration still exits 0.
  manager_env=$(systemctl --user show-environment) || manager_env=
  if grep -q '^WAYLAND_DISPLAY=' <<<"$manager_env"; then
    pid=$(systemctl --user show -p MainPID --value xdg-desktop-portal.service) || pid=
    if [[ $pid =~ ^[1-9][0-9]*$ && -r /proc/$pid/environ ]]; then
      portal_env=$(tr '\0' '\n' <"/proc/$pid/environ") || portal_env=
      current=$(systemctl --user show -p MainPID --value xdg-desktop-portal.service) || current=
      if [[ $current == "$pid" ]] && { ! grep -q '^WAYLAND_DISPLAY=' <<<"$portal_env" ||
        ! grep -q '^QT_QPA_PLATFORM=' <<<"$portal_env"; }; then
        systemctl --user try-restart xdg-desktop-portal.service
      fi
    fi
  fi
fi
