echo "Restore the keyboard backlight after hibernation"

# omarchy-hibernation-setup copies the hook rather than linking it, so an
# install that set up hibernation keeps the old copy, which turns the backlight
# off before hibernating and never turns it back on. Only replace that exact
# stock copy; anything else was changed by the administrator.
hook=/usr/lib/systemd/system-sleep/keyboard-backlight
previous_sha256=79215eed4da8036e25cd70ad09276823aad92d386a68c69d589d587c93b79c60

[[ -f $hook && ! -L $hook ]] || exit 0

digest=$(/usr/bin/sha256sum -- "$hook")
if [[ ${digest%% *} == "$previous_sha256" ]]; then
  # Rename a staged copy into place, so a failed copy leaves the stock hook for a
  # retry to recognize. systemd-sleep skips hidden files, so the stage never runs.
  stage=$(sudo /usr/bin/mktemp -- "${hook%/*}/.keyboard-backlight.omarchy.XXXXXX") || exit 1
  if ! { sudo /usr/bin/install -m 0755 -o root -g root -T \
    "$OMARCHY_PATH/default/systemd/system-sleep/keyboard-backlight" "$stage" &&
    sudo /usr/bin/mv -Tf -- "$stage" "$hook"; }; then
    sudo /usr/bin/rm -f -- "$stage"
    echo "Could not replace $hook; rerun omarchy-migrate to retry" >&2
    exit 1
  fi
fi
