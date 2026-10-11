echo "Name web app windows in their launchers, so titlebars show the app's name"

# Chromium names a web app window after its URL, and the launcher's
# StartupWMClass is how titlebars find the launcher's Name for it. Launchers
# that already name a class, and those with custom commands, are left alone.
for desktop in "${XDG_DATA_HOME:-$HOME/.local/share}"/applications/*.desktop; do
  [[ -f $desktop ]] || continue
  grep -q '^StartupWMClass=' "$desktop" && continue

  url=$(sed -n 's/^Exec=omarchy-launch-webapp "\{0,1\}\([^" ]*\)"\{0,1\}$/\1/p' "$desktop" | head -1)
  [[ -n $url ]] || continue

  sed -i --follow-symlinks "0,/^Exec=/{/^Exec=/a StartupWMClass=$(omarchy-webapp-window-class "${url//%%/%}")
}" "$desktop"
done
