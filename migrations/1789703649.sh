echo "Stop starting Sunshine twice at login"

# The installer used to enable the systemd user unit and also append
# o.launch_on_start("sunshine"), so login started two copies and the extra
# process SIGABRTed. Autostart is the user unit alone now; strip the leftover
# Hyprland line from existing installs. Removal already deletes this line.
file="$HOME/.config/hypr/autostart.lua"
entry='o.launch_on_start("sunshine")'

[[ -f $file ]] || exit 0
grep -Fxq "$entry" "$file" || exit 0
sed -i "\|^$entry$|d" "$file"
