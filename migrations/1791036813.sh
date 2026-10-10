echo "Launch Spotify with native Wayland rendering"

[[ -x /usr/bin/spotify ]] || exit 0

desktop_file="$HOME/.local/share/applications/spotify.desktop"

# Leave a launcher entry the user wrote themselves alone
[[ -f $desktop_file ]] && exit 0

mkdir -p "$HOME/.local/share/applications"
install -m 644 "$OMARCHY_PATH/default/applications/spotify.desktop" "$desktop_file"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
