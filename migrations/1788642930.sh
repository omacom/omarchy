echo "Install ffmpeg 4.4 and zenity so Spotify can play Local Files"

if omarchy-pkg-present spotify; then
  omarchy-pkg-add ffmpeg4.4 zenity
fi
