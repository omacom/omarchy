echo "Let links opened through the portal carry their activation token to the browser"

entry=~/.local/share/applications/omarchy-browser.desktop
if [[ -f $entry ]] && ! grep -qxF "StartupNotify=true" "$entry"; then
  cp -f "$OMARCHY_PATH/applications/omarchy-browser.desktop" "$entry"
  update-desktop-database ~/.local/share/applications
fi
