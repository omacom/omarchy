echo "Route links from every app through the running default browser"

mkdir -p ~/.local/share/applications
cp -f "$OMARCHY_PATH/applications/omarchy-browser.desktop" ~/.local/share/applications/
update-desktop-database ~/.local/share/applications

# Keep an http or https handler the user already set for Hyprland.
list=~/.config/hyprland-mimeapps.list
if [[ ! -f $list ]]; then
  cp "$OMARCHY_PATH/config/hyprland-mimeapps.list" "$list"
elif ! grep -qE '^x-scheme-handler/https?=' "$list"; then
  handlers=$'x-scheme-handler/http=omarchy-browser.desktop\nx-scheme-handler/https=omarchy-browser.desktop'
  if grep -qxF "[Default Applications]" "$list"; then
    awk -v handlers="$handlers" '{ print } $0 == "[Default Applications]" { print handlers }' "$list" >"$list.tmp"
    mv "$list.tmp" "$list"
  else
    printf '\n[Default Applications]\n%s\n' "$handlers" >>"$list"
  fi
fi
