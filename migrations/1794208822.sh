echo "Name the HEY and Zoom web app windows in their launchers, so the dock and titlebars find their windows"

# The HEY and Zoom launchers start Chromium through their own handlers, which
# the earlier web app migration skipped. Launchers that already name a class
# are left alone.
for entry in HEY:hey:chrome-app.hey.com__-Default Zoom:zoom:chrome-app.zoom.us__wc_home-Default; do
  IFS=: read -r file handler class <<<"$entry"
  desktop="${XDG_DATA_HOME:-$HOME/.local/share}/applications/$file.desktop"
  [[ -f $desktop ]] || continue
  grep -q '^StartupWMClass=' "$desktop" && continue
  grep -q "^Exec=omarchy-webapp-handler-$handler" "$desktop" || continue

  target=$(realpath "$desktop")
  CLASS=$class awk '!done && /^Exec=/ { print; print "StartupWMClass=" ENVIRON["CLASS"]; done = 1; next } { print }' "$target" >"$target.omarchy-migrate"
  cat "$target.omarchy-migrate" >"$target"
  rm -f "$target.omarchy-migrate"
done
