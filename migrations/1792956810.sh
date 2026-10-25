echo "Use Adwaita icons for Vantablack and White, whose gray Yaru icon theme does not exist"

# GTK falls back to Adwaita when the named icon theme is missing, but Qt does
# not, so the shell drew no icon for an app without one of its own. The staged
# theme is fixed too, so reapplying it does not bring the missing name back.
staged_icons="$HOME/.local/state/omarchy/current/theme/icons.theme"

is_missing_gray_yaru() {
  [[ $1 == "Yaru-gray" || $1 == "Yaru-grey" ]]
}

if [[ -f $staged_icons ]] && is_missing_gray_yaru "$(<"$staged_icons")"; then
  printf 'Adwaita\n' >"$staged_icons"
fi

if [[ -n ${DBUS_SESSION_BUS_ADDRESS:-} ]]; then
  current=$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null || true)
  if is_missing_gray_yaru "${current//\'/}"; then
    gsettings set org.gnome.desktop.interface icon-theme "Adwaita"
  fi
fi
