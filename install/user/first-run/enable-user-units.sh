#!/bin/bash

# Enable AND start the user systemd units we ship. Runs at first-run rather
# than at finalize-user time because the user manager isn't live during the
# ISO chroot — by first-run, the Hyprland/uwsm session is up and enabling with
# `--no-reload`, followed by a single `daemon-reload` and per-unit `start`,
# writes the .wants symlinks and starts the services in the first session
# without reloading the user manager once per unit. ConditionPath* in the unit
# files keep the enabled units inert on hardware they don't apply to.

set -euo pipefail

systemctl --user daemon-reload
systemctl --user enable --now \
  bt-agent.service \
  owed.service \
  omarchy-recover-internal-monitor.service \
  omarchy-sleep-lock.service \
  omarchy-migrate-notify.service \
  omarchy-fcitx5.service \
  omarchy-crash-watch.service; do
  systemctl --user enable --now "$unit" || failed=1
done

omarchy-hook-install theme-set /usr/share/owe/10-owe-sync
exit "$failed"
