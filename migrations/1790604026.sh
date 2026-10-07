echo "Route fcitx5 D-Bus activation through omarchy-fcitx5.service"

# dbus-broker only reads new activation files on a config reload, so the
# shipped override does nothing for this session until then.
busctl --user call org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus ReloadConfig >/dev/null 2>&1 || true

# A session already caught in the loop has a D-Bus activated fcitx5 owning the
# name. Hand it back to the unit; leave a healthy unit alone, since restarting
# it drops every X11 client's input context for nothing. A user who disabled or
# masked the unit runs fcitx5 their own way, and that one is not ours to kill.
if systemctl --user is-active --quiet graphical-session.target &&
  systemctl --user is-enabled --quiet omarchy-fcitx5.service; then
  owner=$(busctl --user status org.fcitx.Fcitx5 2>/dev/null | sed -n 's/^PID=//p') || true
  main=$(systemctl --user show --property MainPID --value omarchy-fcitx5.service)
  if [[ -n $owner && $owner != "$main" ]]; then
    omarchy-restart-xcompose
  fi
fi
