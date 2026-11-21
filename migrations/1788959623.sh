echo "Mark Omarchy web app launchers so default-browser apps stay in the web app list"

# Only backfill launchers Omarchy already created. Do not stamp arbitrary
# user xdg-open https:// shortcuts — those would show up under Remove → Web App.
# New installs (including default-browser ones) get X-Omarchy-WebApp from
# omarchy-webapp-install going forward.
apps_dir="$HOME/.local/share/applications"
[[ -d $apps_dir ]] || exit 0

shopt -s nullglob
for file in "$apps_dir"/*.desktop; do
  grep -q '^X-Omarchy-WebApp=true' "$file" && continue

  if grep -qE '^Exec=.*(omarchy-launch-webapp|omarchy-webapp-handler)' "$file"; then
    printf 'X-Omarchy-WebApp=true\n' >>"$file"
  fi
done
