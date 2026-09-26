echo "Add transcript download extension (Alt+Shift+S) to Chromium-based browsers"

TRANSCRIPT_EXT="$OMARCHY_PATH/default/chromium/extensions/transcript"

add_transcript_extension() {
  local file=$1

  [[ -f $file ]] || return 0
  grep -q "extensions/transcript" "$file" && return 0

  if grep -q "^--load-extension=" "$file"; then
    sed -i --follow-symlinks "s|^--load-extension=\(.*\)$|--load-extension=\1,$TRANSCRIPT_EXT|" "$file"
  else
    echo "--load-extension=$TRANSCRIPT_EXT" >>"$file"
  fi
}

for conf in chromium chrome google-chrome brave brave-beta brave-nightly brave-origin-beta microsoft-edge-stable; do
  add_transcript_extension "$HOME/.config/$conf-flags.conf"
done

omarchy-pkg-add yt-dlp

# Register the native messaging host that fetches the transcript for the extension.
omarchy-install-chromium-transcript || true
