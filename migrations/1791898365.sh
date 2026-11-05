echo "Speed up the boot menu and keep it quiet until a key is pressed"

# Limine waits out its menu timeout on every boot and draws the menu while
# it does. timeout: 1 with quiet: yes makes the boot silent and
# near-instant; any key still shows the menu, and System > Reboot to Boot
# Menu asks for it explicitly. Only machines that never set a timeout of
# their own get the new one: an uncommented timeout: is the user's and
# stays. quiet is added wherever it is missing. Running this twice
# changes nothing the second time.

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
  sudo -v
  sudo test -f "$limine_conf" || exit 0
fi

# limine-snapper-sync rewrites limine.conf after every snapshot, and the
# package installs in earlier migrations take snapshots. Edit under the lock
# the Limine tools use, or a sync that read the file earlier writes it back
# over these edits. Fail unless both lines are in the file, so the migration
# stays pending instead of announcing a quiet boot it did not get.
result=$(sudo flock /run/lock/boot-partition.lock bash -c '
  conf=$1
  if ! grep -Eqi "^[[:space:]]*timeout:" "$conf"; then
    if grep -Eqi "^[[:space:]]*#timeout:" "$conf"; then
      sed -i -E "s/^[[:space:]]*#timeout:.*/timeout: 1/I" "$conf"
    else
      sed -i "1i timeout: 1" "$conf"
    fi
    echo set_timeout
  fi
  if ! grep -Eqi "^[[:space:]]*quiet:" "$conf"; then
    sed -i -E "/^[[:space:]]*timeout:/I a quiet: yes" "$conf"
    echo added_quiet
  fi
  grep -Eqi "^[[:space:]]*timeout:" "$conf" && grep -Eqi "^[[:space:]]*quiet:" "$conf"
' _ "$limine_conf") || {
  echo "Could not set the quiet boot menu in $limine_conf; it will be retried on the next update" >&2
  exit 1
}

set_timeout=""
added_quiet=""
[[ $result == *set_timeout* ]] && set_timeout=1
[[ $result == *added_quiet* ]] && added_quiet=1

if [[ -n $set_timeout && -n $added_quiet ]]; then
  echo "The boot menu now waits 1 second and stays quiet until a key is pressed"
elif [[ -n $set_timeout ]]; then
  echo "The boot menu now waits 1 second"
elif [[ -n $added_quiet ]]; then
  echo "The boot now stays quiet until a key is pressed; the boot timeout was left as it was"
fi
