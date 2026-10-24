echo "Run Spotify on native Wayland through its flags file"

[[ -x /usr/bin/spotify ]] || exit 0

flags_file="$HOME/.config/spotify-flags.conf"

# Spotify's bundled Chromium crashes its GPU process under XWayland (an
# upstream Spotify/CEF bug since 1.3.4.258); native Wayland avoids it. Keep
# flags the user already set, including any platform choice, and only add the
# switch when nothing has chosen one.
if [[ ! -f $flags_file ]]; then
  mkdir -p "$HOME/.config"
  cp "$OMARCHY_PATH/config/spotify-flags.conf" "$flags_file"
elif ! grep -q -- '^--ozone-platform=' "$flags_file"; then
  [[ -n $(tail -c1 "$flags_file") ]] && echo >>"$flags_file"
  echo '--ozone-platform=wayland' >>"$flags_file"
fi
