echo "Open in Console from Nautilus now opens the default terminal"

omarchy-refresh-applications

# The session bus only reads new service files on reload; without this it waits for the next login.
busctl --user call org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus ReloadConfig >/dev/null 2>&1 || true
