echo "Add the Omareader extension to Chromium-based browsers"

OMAREADER_EXT="$OMARCHY_PATH/default/chromium/extensions/omareader"

add_omareader_extension() {
  local file=$1

  [[ -f $file ]] || return 0
  grep -q "extensions/omareader" "$file" && return 0

  if grep -q "^--load-extension=" "$file"; then
    sed -i --follow-symlinks "s|^--load-extension=\(.*\)$|--load-extension=\1,$OMAREADER_EXT|" "$file"
  else
    [[ -n $(tail -c1 "$file") ]] && echo >>"$file"
    echo "--load-extension=$OMAREADER_EXT" >>"$file"
  fi
}

for conf in chromium chrome google-chrome brave brave-beta brave-nightly brave-origin microsoft-edge-stable; do
  add_omareader_extension "$HOME/.config/$conf-flags.conf"
done

# Register the native messaging host that streams the theme palette to it.
omarchy-install-chromium-omareader
