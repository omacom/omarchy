echo "Fix blank Spotify video player"

[[ -x /usr/bin/spotify ]] || exit 0

flags_file="$HOME/.config/spotify-flags.conf"

# Spotify's hardware video decoding renders music videos and video podcasts as a blank white
# box under XWayland. Keep any flags the user already set and only add the decode switch.
if [[ ! -f $flags_file ]]; then
  mkdir -p "$HOME/.config"
  cp "$OMARCHY_PATH/config/spotify-flags.conf" "$flags_file"
elif ! grep -qx -- '--disable-accelerated-video-decode' "$flags_file"; then
  [[ -n $(tail -c1 "$flags_file") ]] && echo >>"$flags_file"
  echo '--disable-accelerated-video-decode' >>"$flags_file"
fi
