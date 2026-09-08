echo "Handle calendar files and webcal links with HEY unless a handler is already set"

app_dir="$HOME/.local/share/applications"
mkdir -p "$app_dir"

for app in HEY.desktop "Google Calendar.desktop"; do
  src="$OMARCHY_PATH/applications/$app"
  if [[ -f "$src" ]]; then
    cp "$src" "$app_dir/$app"
  fi
done
update-desktop-database "$app_dir" &>/dev/null || true

if [[ -z $(xdg-mime query default text/calendar 2>/dev/null || true) ]]; then
  xdg-mime default HEY.desktop text/calendar
  xdg-mime default HEY.desktop application/ics
  xdg-mime default HEY.desktop text/x-vcalendar
  xdg-mime default HEY.desktop x-scheme-handler/webcal
fi
