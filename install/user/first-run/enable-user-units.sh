#!/bin/bash

# Enable AND start the user systemd units we ship. Runs at first-run rather
# than at finalize-user time because the user manager isn't live during the
# ISO chroot — by first-run, the Hyprland/uwsm session is up and
# `systemctl --user enable --now` both writes the correct .wants symlinks
# (based on each unit's [Install]/WantedBy) and starts the services so the
# first session has bluetooth pairing, sleep lock, etc. live immediately
# instead of waiting for the next login. ConditionPath* in the unit files
# keep the enabled units inert on hardware they don't apply to.

set -euo pipefail

systemctl --user daemon-reload
systemctl --user enable --now \
  bt-agent.service \
  owed.service \
  omarchy-recover-internal-monitor.service \
  omarchy-sleep-lock.service \
  omarchy-migrate-notify.service \
  omarchy-fcitx5.service \
  omarchy-crash-watch.service

# Enable idle-inhibit on its own. systemd enable --now fails the whole list
# when any unit name is missing, which would leave sleep-lock and fcitx
# unenabled until omarchy-settings ships this unit. Link the checkout copy
# when the packaged unit is not there yet (same fallback as the migration).
user_config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
unit_source="$OMARCHY_PATH/default/systemd/user/omarchy-idle-inhibit.service"
unit_pkg="/usr/lib/systemd/user/omarchy-idle-inhibit.service"
if [[ ! -f $unit_pkg && -f $unit_source ]]; then
  mkdir -p "$user_config_home/systemd/user"
  ln -sfn "$unit_source" "$user_config_home/systemd/user/omarchy-idle-inhibit.service"
  systemctl --user daemon-reload
fi
systemctl --user enable --now omarchy-idle-inhibit.service || true

omarchy-hook-install theme-set /usr/share/owe/10-owe-sync
