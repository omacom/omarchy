echo "Mark Omarchy web app launchers so default-browser apps stay in the web app list"

apps_dir="$HOME/.local/share/applications"
[[ -d $apps_dir ]] || return 0

shopt -s nullglob
for file in "$apps_dir"/*.desktop; do
  grep -q '^X-Omarchy-WebApp=true' "$file" && continue

  if grep -qE '^Exec=.*(omarchy-launch-webapp|omarchy-webapp-handler)' "$file" ||
    grep -qE '^Exec=xdg-open[[:space:]]+["'\'']?https?://' "$file"; then
    printf 'X-Omarchy-WebApp=true\n' >>"$file"
  fi
done
