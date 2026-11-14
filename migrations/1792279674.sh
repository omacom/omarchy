echo "Work around broken Ghostty D-Bus activation so Ghostty launches from the menu"

# The ghostty package ships its desktop file with DBusActivatable=true, so menu
# launches go through D-Bus activation handled by
# app-com.mitchellh.ghostty.service (--initial-window=false). That service fails
# to start ("lacks handler for reload signal USR2, refusing service startup"),
# so menu launches silently do nothing while running the binary directly works.
# Point the local override at Exec until the packaging is fixed upstream.
# See https://github.com/omacom/omarchy/issues/15779

omarchy-cmd-present ghostty || exit 0

system_desktop="/usr/share/applications/com.mitchellh.ghostty.desktop"
[[ -f $system_desktop ]] || exit 0
grep -q "^DBusActivatable=true" "$system_desktop" || exit 0

app_dir="$HOME/.local/share/applications"
override="$app_dir/com.mitchellh.ghostty.desktop"
mkdir -p "$app_dir"

if [[ ! -e $override ]]; then
  cp "$system_desktop" "$override"
fi

# Edit the main group even when desktop actions follow it; preserve custom keys.
desktop-file-edit --set-key=DBusActivatable --set-value=false "$override"

update-desktop-database "$app_dir"
