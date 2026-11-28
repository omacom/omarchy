echo "Repair the quiet boot menu a snapshot sync overwrote"

# Migration 1791898365 sets timeout: 1 and quiet: yes, but a
# limine-snapper-sync write could land over its edits and leave the marker
# set. Only a file still in that untouched state (no timeout: and no quiet:
# line) is repaired; a user's own lines are left alone.

limine_conf="${OMARCHY_LIMINE_CONF:-}"
if [[ -z $limine_conf ]]; then
  esp=""
  if [[ -r /etc/default/limine ]]; then
    esp=$(sed -n 's/^ESP_PATH=["'\'']\?\([^"'\'']*\).*/\1/p' /etc/default/limine | tail -n 1)
  fi
  limine_conf="${esp:-/boot}/limine.conf"
fi

if [[ ! -f $limine_conf ]]; then
  # The ESP is often mounted umask=0077, so an unreadable menu is not a
  # missing one; and a denied prompt must leave this migration pending,
  # not done, so authentication failure stops it here.
  sudo true
  sudo test -f "$limine_conf" || exit 0
fi

sudo flock /run/lock/boot-partition.lock bash -c '
  conf=$1
  if ! grep -Eqi "^[[:space:]]*(timeout|quiet):" "$conf"; then
    # Both lines in one rewrite, so an interrupted run leaves neither.
    if grep -Eqi "^[[:space:]]*#timeout:" "$conf"; then
      sed -i -E "0,/^[[:space:]]*#timeout:.*/I s//timeout: 1\nquiet: yes/" "$conf"
    else
      sed -i "1i timeout: 1\nquiet: yes" "$conf"
    fi
    grep -Eqi "^[[:space:]]*timeout:" "$conf" && grep -Eqi "^[[:space:]]*quiet:" "$conf" || exit 1
  fi

  # Retry enrollment even when a previous run already repaired the menu.
  enroll=$(sed -nE "s/^[[:space:]]*ENABLE_ENROLL_LIMINE_CONFIG[[:space:]]*=[[:space:]]*//p" /etc/default/limine 2>/dev/null | tail -n 1)
  if [[ $enroll =~ ^\"?yes\"?$ ]]; then
    limine-enroll-config
  fi
' _ "$limine_conf" || {
  echo "Could not set the quiet boot menu in $limine_conf; it will be retried on the next update" >&2
  exit 1
}
