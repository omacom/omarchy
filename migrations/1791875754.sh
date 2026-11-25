echo "Name web app windows in launchers that run their own command"

# A web app installed with its own Exec, such as HEY with its mailto handler,
# got no StartupWMClass, so nothing tied its window to its launcher: the dock
# left it out and titlebars showed the page title. Its window class follows
# from the URL it opens, as it does for every other web app.

applications=$HOME/.local/share/applications

for desktop_file in "$applications"/*.desktop; do
  [[ -f $desktop_file ]] || continue
  grep -q '^StartupWMClass=' "$desktop_file" && continue

  # An entry without an Exec, such as a Hidden=true override, opens nothing.
  exec_line=$(grep -m1 '^Exec=' "$desktop_file" || true)
  url=""

  if [[ $exec_line =~ ^Exec=omarchy-webapp-handler-hey ]]; then
    url="https://app.hey.com"
  elif [[ $exec_line =~ ^Exec=omarchy-launch-webapp[[:space:]]+\"?([^\"[:space:]]+) ]]; then
    url=${BASH_REMATCH[1]}
  fi

  [[ -n $url ]] || continue

  window_class=$(omarchy-webapp-window-class "$url") || continue
  if [[ -n $window_class ]]; then
    printf 'StartupWMClass=%s\n' "$window_class" >>"$desktop_file"
  fi
done
