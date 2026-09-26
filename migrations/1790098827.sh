echo "Refresh system-sleep keyboard-backlight hook to restore after resume"

# Hibernation setup and migration 1788662350 install this hook under
# /usr/lib/systemd/system-sleep. Refresh the copy when present so existing
# installs pick up pre-save / post-restore without requiring hibernation
# re-setup. Leave machines that never installed the hook alone.

system_sleep_dir=/usr/lib/systemd/system-sleep
keyboard_source="$OMARCHY_PATH/default/systemd/system-sleep/keyboard-backlight"
keyboard_dest="$system_sleep_dir/keyboard-backlight"

[[ -f $keyboard_source ]] || exit 0
[[ -e $keyboard_dest || -L $keyboard_dest ]] || exit 0

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

if [[ -f $keyboard_dest && ! -L $keyboard_dest ]]; then
  if [[ -r $keyboard_dest ]] && /usr/bin/cmp -s -- "$keyboard_source" "$keyboard_dest"; then
    exit 0
  fi
fi

stage=$(as_root /usr/bin/mktemp -- "$system_sleep_dir/.keyboard-backlight.omarchy.XXXXXX") || exit 1
if as_root /usr/bin/install -m 0755 -o root -g root -T "$keyboard_source" "$stage" &&
  as_root /usr/bin/mv -Tf -- "$stage" "$keyboard_dest"; then
  :
else
  as_root /usr/bin/rm -f -- "$stage"
  echo "Could not refresh the keyboard-backlight system-sleep hook" >&2
  exit 1
fi
