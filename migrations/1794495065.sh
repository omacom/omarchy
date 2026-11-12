echo "Add Terminal and Browser to the app launcher"

# Only these two, so apps the user removed from the launcher stay removed.
mkdir -p ~/.local/share/applications
cp "$OMARCHY_PATH/applications/omarchy-terminal.desktop" "$OMARCHY_PATH/applications/omarchy-browser.desktop" ~/.local/share/applications/
update-desktop-database ~/.local/share/applications
omarchy-theme-set-icons || true
