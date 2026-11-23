echo "Snapshot /home hourly so deleted files can be brought back"

omarchy-cmd-present snapper btrfs || exit 0

# The setup that shipped beside this migration, which knows about /home.
OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
snapper_config_script="$OMARCHY_PATH/install/config/snapper.sh"

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

# Machine-wide, so a second user on the same box finds it already done.
if grep -qx 'SNAPPER_CONFIGS="root home"' /etc/conf.d/snapper 2>/dev/null && systemctl is-enabled --quiet snapper-timeline.timer 2>/dev/null; then
  exit 0
fi

as_root env OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail "$snapper_config_script"
