echo "Install the Wi-Fi app launcher so the network panel is reachable without the bar widget"

src="$OMARCHY_PATH/applications/Wi-Fi.desktop"
dest="$HOME/.local/share/applications/Wi-Fi.desktop"

[[ -f $src ]] || exit 0
[[ -f $dest ]] && exit 0

mkdir -p "$HOME/.local/share/applications"
cp "$src" "$dest"
update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
