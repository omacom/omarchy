echo "Check network connectivity against ping.omacom.io"

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

# omarchy-settings ships the drop-in; a running NetworkManager only reads it on
# reload. A failed reload fails the migration so it stays pending.
if systemctl is-active --quiet NetworkManager; then
  as_root nmcli general reload conf
fi
