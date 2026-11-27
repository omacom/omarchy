echo "Stop starting Sunshine twice at login"

# Keep a user's sole launcher when they disabled the unit to avoid the double start.
# An explicit reinstall enables the unit and removes the legacy launcher instead.
file="$HOME/.config/hypr/autostart.lua"
entry='o.launch_on_start("sunshine")'

if [[ -f $file ]] && grep -Fxq "$entry" "$file" && systemctl --user is-enabled --quiet app-dev.lizardbyte.app.Sunshine.service; then
  sed -i "\|^$entry$|d" "$file"
fi
