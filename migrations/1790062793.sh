echo "Repair Sunshine Admin web app launcher"

# omarchy-install-service-sunshine used to build the admin shortcut as
#   omarchy-launch-webapp https://localhost:47990 --ignore-certificate-errors
# and omarchy-webapp-install writes that command verbatim into the .desktop
# Exec. The flag is not scoped to localhost: it disables certificate validation
# for the whole browser process, and Chromium is a singleton per profile, so
# opening this entry before the browser was running turned off TLS enforcement
# for every origin in that session.
#
# omarchy-launch-webapp now refuses the flag, which would leave an existing
# entry failing to launch. Strip it so the shortcut keeps working, and only
# from the exact generated command, so a hand-edited entry is left alone.
desktop_file="$HOME/.local/share/applications/Sunshine Admin.desktop"

[[ -f $desktop_file ]] || return 0 2>/dev/null || exit 0

generated='^Exec=omarchy-launch-webapp (https://localhost:47990) --ignore-certificate-errors$'
exec_line=$(grep -m1 '^Exec=' "$desktop_file" 2>/dev/null || true)

if [[ $exec_line =~ $generated ]]; then
  url=${BASH_REMATCH[1]}
  tmp=$(mktemp)
  sed "s|^Exec=.*|Exec=omarchy-launch-webapp $url|" "$desktop_file" >"$tmp"
  mv -f "$tmp" "$desktop_file"
  chmod +x "$desktop_file"
  echo "Removed --ignore-certificate-errors from the Sunshine Admin shortcut."
  echo "The self-signed page now asks once instead of disabling TLS checks browser-wide."
elif [[ $exec_line == *--ignore-certificate-errors* ]]; then
  echo "Sunshine Admin shortcut carries --ignore-certificate-errors but has been edited;"
  echo "leaving it alone. Remove that flag by hand: $desktop_file"
fi
