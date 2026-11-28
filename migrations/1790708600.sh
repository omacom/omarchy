echo "Give agent windows a desktop entry so they pick up an icon"

mkdir -p "$HOME/.local/share/applications"
cp "$OMARCHY_PATH/applications/org.omarchy.agent.desktop" "$HOME/.local/share/applications/org.omarchy.agent.desktop"
update-desktop-database "$HOME/.local/share/applications"
