echo "Add Microsoft Teams meeting handler and Chromium join extension"

src="$OMARCHY_PATH/applications/Microsoft Teams Meeting.desktop"
dest="$HOME/.local/share/applications/Microsoft Teams Meeting.desktop"
mkdir -p "$HOME/.local/share/applications"
if [[ ! -f $dest ]] || ! cmp -s "$src" "$dest"; then
  cp "$src" "$dest"
fi
update-desktop-database "$HOME/.local/share/applications"

TEAMS_JOIN_EXT="$OMARCHY_PATH/default/chromium/extensions/teams-join"

add_teams_join_extension() {
  local file=$1

  [[ -f $file ]] || return 0
  grep -q "extensions/teams-join" "$file" && return 0

  if grep -q "^--load-extension=" "$file"; then
    sed -i --follow-symlinks "s|^--load-extension=\(.*\)$|--load-extension=\1,$TEAMS_JOIN_EXT|" "$file"
  else
    echo "--load-extension=$TEAMS_JOIN_EXT" >>"$file"
  fi
}

for conf in chromium chrome google-chrome brave brave-beta brave-nightly brave-origin-beta microsoft-edge-stable brave-origin; do
  add_teams_join_extension "$HOME/.config/$conf-flags.conf"
done

echo "Restart Chromium/Brave to load the Teams extension"
