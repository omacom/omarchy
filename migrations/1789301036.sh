echo "Restore the keyboard backlight level after hibernation"

system_sleep_dir=/usr/lib/systemd/system-sleep
hook_source="$OMARCHY_PATH/default/systemd/system-sleep/keyboard-backlight"
hook_destination="$system_sleep_dir/keyboard-backlight"
# The hook exactly as this release replaces it: it cleared the LED before S4 and
# had no post phase, so the ASUS keyboard came back dark after every hibernate
# and stayed dark until a brightness key was pressed. Matching that file keeps
# this migration off an administrator's own hook, and it makes a second run a
# no-op once the replacement is in place.
previous_hook_sha256=79215eed4da8036e25cd70ad09276823aad92d386a68c69d589d587c93b79c60

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

if [[ ! -f $hook_destination ]]; then
  exit 0
fi

installed_sha256=$(as_root sha256sum "$hook_destination" | cut -d' ' -f1)

if [[ $installed_sha256 != "$previous_hook_sha256" ]]; then
  echo "Keyboard backlight hook is not the one this release replaces; leaving it alone"
  exit 0
fi

stage=$(as_root mktemp "${hook_destination%/*}/.${hook_destination##*/}.omarchy.XXXXXX") || exit 1

# Staged root-owned beside the destination so the final rename is an atomic swap
# and a failure cannot leave a half-written hook for systemd-sleep to execute.
if as_root install -m 0755 -o root -g root -T "$hook_source" "$stage" &&
  as_root mv -Tf -- "$stage" "$hook_destination"; then
  echo "Keyboard backlight now returns to its level after hibernation"
else
  as_root rm -f -- "$stage"
  exit 1
fi
