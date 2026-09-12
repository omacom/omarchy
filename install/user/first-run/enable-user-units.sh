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
  omarchy-recover-internal-monitor.service
  omarchy-sleep-lock.service
  omarchy-migrate-notify.service
  omarchy-fcitx5.service
  omarchy-crash-watch.service
)

systemctl --user daemon-reload

failed=0
for unit in "${units[@]}"; do
  if ! systemctl --user enable --now "$unit"; then
    echo "warning: could not enable $unit" >&2
    failed=1
  fi
done

# Non-zero only if every unit failed — a single missing unit must not block
# first-run completion or the remaining units that did enable.
if (( failed )) && ! systemctl --user is-enabled --quiet bt-agent.service 2>/dev/null &&
  ! systemctl --user is-enabled --quiet omarchy-fcitx5.service 2>/dev/null &&
  ! systemctl --user is-enabled --quiet omarchy-crash-watch.service 2>/dev/null &&
  ! systemctl --user is-enabled --quiet omarchy-sleep-lock.service 2>/dev/null &&
  ! systemctl --user is-enabled --quiet omarchy-migrate-notify.service 2>/dev/null &&
  ! systemctl --user is-enabled --quiet omarchy-recover-internal-monitor.service 2>/dev/null; then
  echo "error: no omarchy user units could be enabled" >&2
  exit 1
fi
