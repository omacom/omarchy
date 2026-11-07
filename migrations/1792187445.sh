echo "Add Rex, the regular expression workbench, to Apps"

mkdir -p "$HOME/.local/share/applications"
cp "$OMARCHY_PATH/applications/Rex.desktop" "$HOME/.local/share/applications/"
update-desktop-database "$HOME/.local/share/applications"
