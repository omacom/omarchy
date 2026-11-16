echo "Name web app windows in their launchers, so titlebars show the app's name"

# Chromium names a web app window after its URL, and the launcher's
# StartupWMClass is how titlebars find the launcher's Name for it. Launchers
# that already name a class, and those with custom commands, are left alone.
for desktop in "${XDG_DATA_HOME:-$HOME/.local/share}"/applications/*.desktop; do
  [[ -f $desktop ]] || continue
  grep -q '^StartupWMClass=' "$desktop" && continue

  exec_line=$(grep -m1 '^Exec=omarchy-launch-webapp ' "$desktop") || continue

  # The installer escaped the URL twice: as one Exec argument, then as desktop
  # file text. Undo the file layer, then the argument quoting.
  url=${exec_line#Exec=omarchy-launch-webapp }
  url=${url//\\\\/\\}
  if [[ $url == \"*\" ]]; then
    url=$(sed 's/\\\(.\)/\1/g' <<<"${url:1:${#url}-2}")
  fi
  url=${url//%%/%}
  [[ $url =~ ^https?:// && $url != *[[:space:]]* ]] || continue

  class=$(omarchy-webapp-window-class "$url")
  target=$(realpath "$desktop")
  CLASS=${class//\\/\\\\} awk '!done && /^Exec=/ { print; print "StartupWMClass=" ENVIRON["CLASS"]; done = 1; next } { print }' "$target" >"$target.omarchy-migrate" &&
    cat "$target.omarchy-migrate" >"$target"
  rm -f "$target.omarchy-migrate"
done
