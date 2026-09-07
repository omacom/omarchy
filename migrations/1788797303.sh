echo "Stop fprintd before suspend so the reader cannot be opened inside a sleep transition"

# The lock screen starts after PrepareForSleep(true), and pam_fprintd
# D-Bus-activates fprintd once the lock is already in progress. fprintd then
# asks logind for a delay inhibitor, but logind has already stopped honouring
# new inhibitors, so the reader can be cut mid-transaction. Stopping fprintd in
# the pre-sleep hook keeps it from being opened while the machine is going down.
# fprintd is Type=dbus, so it re-activates on the next unlock attempt.
hook_source="$OMARCHY_PATH/default/systemd/system-sleep/50-fprintd-release"
hook_dest=/usr/lib/systemd/system-sleep/50-fprintd-release

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

[[ -e $hook_source ]] || exit 0

if [[ -e $hook_dest ]] && cmp -s "$hook_source" "$hook_dest"; then
  exit 0
fi

as_root install -Dm755 "$hook_source" "$hook_dest"
