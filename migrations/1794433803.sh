echo "Run the native Spotify client on Wayland so its GPU process stops crashing under XWayland"

if [[ -x /usr/bin/spotify && ! -f ~/.config/spotify-flags.conf ]]; then
  echo "--ozone-platform=wayland" >~/.config/spotify-flags.conf
fi
