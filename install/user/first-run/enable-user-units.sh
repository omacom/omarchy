#!/bin/bash

# Enable AND start the user systemd units we ship. Runs at first-run rather
# than at finalize-user time because the user manager isn't live during the
# ISO chroot — by first-run, the Hyprland/uwsm session is up and enabling with
# `--no-reload`, followed by a single `daemon-reload` and per-unit `start`,
# writes the .wants symlinks and starts the services in the first session
# without reloading the user manager once per unit. ConditionPath* in the unit
# files keep the enabled units inert on hardware they don't apply to.

set -euo pipefail

omarchy-input-method configure --defaults || echo "Input method defaults deferred; run omarchy setup input after login." >&2

# The settings package lists user units explicitly. Until it ships this one
# to /usr/lib/systemd/user, stage it from the omarchy tree so enable
# can find it. Prefer the packaged copy once it exists.
stage_user_unit() {
  local name=$1
  local src="$OMARCHY_PATH/default/systemd/user/$name"
  if [[ $name == "omarchy-wifi-recover.service" ]]; then
    src="$OMARCHY_PATH/install/helpers/wifi-recover.service"
  fi
  local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  local staged="$config_home/systemd/user/$name"
  if [[ -f /usr/lib/systemd/user/$name ]]; then
    if [[ -f $staged ]] && cmp -s "$staged" "/usr/lib/systemd/user/$name"; then
      rm -f "$staged"
    fi
    return 0
  fi

  [[ -f $src ]] || return 0
  # first-run reruns with --force, so never clobber a copy already there.
  [[ -f $staged ]] && return 0

  install -Dm644 "$src" "$staged"
}

stage_user_unit omarchy-wifi-recover.service

# Enable one at a time without reloading on every call: given a list, systemctl
# enables none of it when it cannot find one unit, while 7 separate reloads
# stall the user manager during first-login startup.
units=(
  bt-agent.service
  owed.service
  omarchy-recover-internal-monitor.service
  omarchy-sleep-lock.service
  omarchy-wifi-recover.service
  omarchy-migrate-notify.service
  omarchy-fcitx5.service
  omarchy-crash-watch.service
)

failed=0
enabled=()
for unit in "${units[@]}"; do
  if systemctl --user enable --no-reload "$unit"; then
    enabled+=("$unit")
  else
    failed=1
  fi
done

systemctl --user daemon-reload

# Start one at a time too: a multi-unit start runs as one systemd transaction,
# so one broken unit could stop the rest from starting.
for unit in "${enabled[@]}"; do
  systemctl --user start "$unit" || failed=1
done

omarchy-hook-install theme-set /usr/share/owe/10-owe-sync
exit "$failed"
