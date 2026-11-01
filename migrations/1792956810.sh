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

current_icon_theme() {
  local current
  current=$(gsettings get org.gnome.desktop.interface icon-theme)
  printf '%s\n' "${current//\'/}"
}

# A run without a user session to write the setting through stays pending, so
# the next run fixes it instead of marking it done.
if is_missing_gray_yaru "$(current_icon_theme)"; then
  gsettings set org.gnome.desktop.interface icon-theme "Adwaita"
  if is_missing_gray_yaru "$(current_icon_theme)"; then
    echo "Could not set the icon theme to Adwaita; run omarchy-migrate again from your desktop session" >&2
    exit 1
  fi
fi
