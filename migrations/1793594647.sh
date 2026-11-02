echo "Theme the GNOME Keyring password prompt with the current Omarchy theme"

mkdir -p ~/.local/share/themes/omarchy-gcr-prompter/gtk-3.0 ~/.local/share/dbus-1/services
ln -snf "$HOME/.local/state/omarchy/current/theme/gcr-prompter.css" ~/.local/share/themes/omarchy-gcr-prompter/gtk-3.0/gtk.css
cp --update=none "$OMARCHY_PATH/default/gcr/org.gnome.keyring.SystemPrompter.service" ~/.local/share/dbus-1/services/
# The bus only watches service directories that existed when it last loaded.
busctl --user call org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus ReloadConfig >/dev/null 2>&1 || true

# The current theme was staged before its template existed.
omarchy-theme-refresh
