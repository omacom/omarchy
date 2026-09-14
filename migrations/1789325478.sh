echo "Enabling native Wayland rendering for Spotify"

[[ -x /usr/bin/spotify ]] || exit 0

flags_file="$HOME/.config/spotify-flags.conf"

[[ -f $flags_file ]] && grep -q -- "--ozone-platform=wayland" "$flags_file" && exit 0

mkdir -p ~/.config
cp -f "$OMARCHY_PATH/config/spotify-flags.conf" "$flags_file"
