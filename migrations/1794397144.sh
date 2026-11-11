echo "Drop the Yaru icon theme, now that Files draws its own icons"

# Only Yaru itself goes: removing its dependencies as well (pacman -s) would
# take whatever arrived with it first. It stays where another package needs it.
if pacman -Qttq yaru-icon-theme &>/dev/null; then
  sudo pacman -Rn --noconfirm yaru-icon-theme
fi

# Setup linked Adwaita's back and forward arrows into Yaru for Nautilus, outside
# the package, so removing it can leave that folder behind with those links and
# a stale icon cache. Clear what's left once Yaru is gone and no package owns it.
yaru=/usr/share/icons/Yaru
if [[ -d $yaru && ! -e $yaru/index.theme ]] && ! pacman -Qqo "$yaru" &>/dev/null; then
  sudo rm -rf "$yaru"
fi

# GTK and Qt apps that named a Yaru colour, Omarchy's old default, get the
# current theme's icons again, which is Adwaita unless it names another
# installed icon theme. An icon theme the user picked themselves stays.
if [[ -n ${DBUS_SESSION_BUS_ADDRESS:-} && $(gsettings get org.gnome.desktop.interface icon-theme) == "'Yaru"* ]]; then
  omarchy-theme-set-gnome
fi

qt_config="${XDG_CONFIG_HOME:-$HOME/.config}/qtengine/config.json"
if [[ -f $qt_config && $(jq -r '.theme.iconTheme // empty' "$qt_config") == Yaru* ]]; then
  omarchy-theme-set-qt
fi
