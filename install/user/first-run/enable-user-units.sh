#!/bin/bash

# Enable AND start the user systemd units we ship. Runs at first-run rather
# than at finalize-user time because the user manager isn't live during the
# ISO chroot — by first-run, the Hyprland/uwsm session is up and
# `systemctl --user enable --now` both writes the correct .wants symlinks
# (based on each unit's [Install]/WantedBy) and starts the services so the
# first session has bluetooth pairing, sleep lock, etc. live immediately
# instead of waiting for the next login. ConditionPath* in the unit files
# keep the enabled units inert on hardware they don't apply to.
#
# Enable one unit at a time. systemctl validates an entire multi-unit list
# before applying any of it, so one missing unit (for example a package that
# forgot to install a unit into /usr/lib/systemd/user/) would leave every
# later unit disabled under set -e (issue #10484).

set -euo pipefail

units=(
  bt-agent.service
  owed.service
  omarchy-recover-internal-monitor.service
  omarchy-sleep-lock.service
  omarchy-migrate-notify.service
  omarchy-fcitx5.service
  omarchy-crash-watch.service
)

systemctl --user daemon-reload

enabled=0
for unit in "${units[@]}"; do
  if systemctl --user enable --now "$unit"; then
    enabled=1
  else
    echo "warning: could not enable $unit" >&2
  fi
done

omarchy-hook-install theme-set /usr/share/owe/10-owe-sync

# A unit that fails must not fail the step while others enabled, or first-run
# never completes; fail it only when none did.
if (( ! enabled )); then
  echo "error: no omarchy user units could be enabled" >&2
  exit 1
fi
