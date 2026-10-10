echo "Enable coredump completion events and restart the crash watcher"

# Package-owned drop-ins are already installed. Create the event directory
# without waiting for reboot and load ExecStopPost for future coredumps.
sudo systemd-tmpfiles --create /etc/tmpfiles.d/omarchy-crash-events.conf
sudo systemctl daemon-reload

# The unit's ConditionPathExists re-checks the same toggle flag at every
# start, so a watcher the user disabled stays off: honoring the flag here
# makes this migration a no-op for them. Only nudge a watcher that is
# actually running; a stopped one stays stopped. A requested restart is left
# to fail loudly: the migration stays unmarked so omarchy-migrate retries it,
# instead of recording a success the watcher did not get.
[[ -f "$HOME/.local/state/omarchy/toggles/crash-capture-off" ]] && exit 0

if systemctl --user is-active --quiet omarchy-crash-watch.service; then
  systemctl --user restart omarchy-crash-watch.service
fi
