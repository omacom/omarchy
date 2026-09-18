echo "Enable the Omarchy wallpaper portal backend for this user"

# Ships the backend definition and D-Bus activation entry into user-level XDG
# paths so "Set as Background" in Files works without waiting for the
# omarchy-settings package to place the system-wide copies.
#
# No portal routing config is shipped here: xdg-desktop-portal routes an
# interface to whichever registered backend implements it when no config entry
# exists, and writing the user's hyprland-portals.conf would wipe custom
# settings (e.g. a custom file chooser). The packaged etc/xdg
# hyprland-portals.conf gains the explicit
# org.freedesktop.impl.portal.Wallpaper=omarchy line once omarchy-settings
# carries it.

portal="$OMARCHY_PATH/default/xdg-desktop-portal/portals/omarchy.portal"
service="$OMARCHY_PATH/default/dbus-1/services/org.freedesktop.impl.portal.desktop.omarchy.service"

[[ -f $portal ]] || exit 0
[[ -f $service ]] || exit 0

mkdir -p "$HOME/.local/share/xdg-desktop-portal/portals" "$HOME/.local/share/dbus-1/services"
cp "$portal" "$HOME/.local/share/xdg-desktop-portal/portals/"
cp "$service" "$HOME/.local/share/dbus-1/services/"

# The session bus caches the activation service list, and xdg-desktop-portal
# only reads portal backends and config at startup.
gdbus call --session --dest org.freedesktop.DBus --object-path /org/freedesktop/DBus --method org.freedesktop.DBus.ReloadConfig >/dev/null || true
systemctl --user try-restart xdg-desktop-portal.service || true
