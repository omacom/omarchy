echo "Add Google Calendar Theme extension to Chromium-based browsers"

GOOGLE_CALENDAR_THEME_EXT="$OMARCHY_PATH/default/chromium/extensions/google-calendar-theme"

add_google_calendar_theme_extension() {
  local file=$1

  [[ -f $file ]] || return 0
  grep -q "extensions/google-calendar-theme" "$file" && return 0

  if grep -q "^--load-extension=" "$file"; then
    sed -i --follow-symlinks "s|^--load-extension=\(.*\)$|--load-extension=\1,$GOOGLE_CALENDAR_THEME_EXT|" "$file"
  else
    [[ -n $(tail -c1 "$file") ]] && echo >>"$file"
    echo "--load-extension=$GOOGLE_CALENDAR_THEME_EXT" >>"$file"
  fi
}

for conf in chromium chrome google-chrome brave brave-beta brave-nightly brave-origin microsoft-edge-stable; do
  add_google_calendar_theme_extension "$HOME/.config/$conf-flags.conf"
done

# Register the native messaging host that streams the theme palette to it.
omarchy-install-chromium-theme
