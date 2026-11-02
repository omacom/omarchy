# Setup user theme folder and seed the default only when no theme exists yet.
mkdir -p ~/.config/omarchy/themes

if [[ ! -s $HOME/.local/state/omarchy/current/theme.name ]]; then
  # iso-chroot and provision-owner both run without a live session to notify.
  if [[ ${OMARCHY_SETUP_CONTEXT:-runtime} != "runtime" ]]; then
    OMARCHY_THEME_HEADLESS=1 omarchy-theme-set "Tokyo Night"
    rm -f ~/.config/chromium/SingletonLock # otherwise archiso owns the Chromium singleton
  else
    omarchy-theme-set "Tokyo Night"
  fi
fi
omarchy-theme-set-pi --activate
omarchy-theme-set-fcitx5 --activate

# The keyring prompt gets its own GTK theme via a user D-Bus entry, so no other GTK app is restyled.
mkdir -p ~/.local/share/themes/omarchy-gcr-prompter/gtk-3.0 ~/.local/share/dbus-1/services
ln -snf "$HOME/.local/state/omarchy/current/theme/gcr-prompter.css" ~/.local/share/themes/omarchy-gcr-prompter/gtk-3.0/gtk.css
cp --update=none "$OMARCHY_PATH/default/gcr/org.gnome.keyring.SystemPrompter.service" ~/.local/share/dbus-1/services/
# The bus only watches service directories that existed when it last loaded.
busctl --user call org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus ReloadConfig >/dev/null 2>&1 || true

mkdir -p ~/.config/btop/themes
ln -snf "$HOME/.local/state/omarchy/current/theme/btop.theme" ~/.config/btop/themes/current.theme
