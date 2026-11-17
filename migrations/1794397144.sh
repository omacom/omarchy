echo "Drop the Yaru icon theme, now that Files draws its own icons"

# Only Yaru itself goes: removing its dependencies as well (pacman -s) would
# take whatever arrived with it first. It stays where another package needs it.
if pacman -Qttq yaru-icon-theme &>/dev/null; then
  sudo pacman -Rn --noconfirm yaru-icon-theme
fi

# Setup linked Adwaita's back and forward arrows into Yaru for Nautilus, outside
# the package, and built an icon cache for them. Once Yaru is gone and no
# package owns the folder, clear exactly those and any folders left empty.
yaru=/usr/share/icons/Yaru
if [[ -d $yaru && ! -e $yaru/index.theme ]] && ! pacman -Qqo "$yaru" &>/dev/null; then
  for icon in go-previous-symbolic go-next-symbolic; do
    link="$yaru/scalable/actions/$icon.svg"
    if [[ -L $link && $(readlink "$link") == "/usr/share/icons/Adwaita/symbolic/actions/$icon.svg" ]]; then
      sudo rm -f "$link"
    fi
  done

  sudo rm -f "$yaru/icon-theme.cache"

  for dir in "$yaru/scalable/actions" "$yaru/scalable" "$yaru"; do
    if [[ -d $dir ]]; then
      sudo rmdir --ignore-fail-on-non-empty "$dir"
    fi
  done
fi

# GTK and Qt apps that named a Yaru colour, Omarchy's old default, get the
# Adwaita icons every theme uses now. An icon theme the user picked themselves
# stays, and so
# does the rest of their GTK appearance. Without a session bus the setting waits
# for the next theme switch; GTK falls back to Adwaita for it meanwhile.
if [[ -n ${DBUS_SESSION_BUS_ADDRESS:-} && $(gsettings get org.gnome.desktop.interface icon-theme) == "'Yaru"* ]]; then
  gsettings set org.gnome.desktop.interface icon-theme "Adwaita"
fi

qt_config="${XDG_CONFIG_HOME:-$HOME/.config}/qtengine/config.json"
if [[ -f $qt_config && $(jq -r '.theme.iconTheme // empty' "$qt_config") == Yaru* ]]; then
  omarchy-theme-set-qt
fi
