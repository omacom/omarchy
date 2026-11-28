echo "Add Herdr, Agent, ChatGPT and Activity Monitor to the app launcher, and let Terminal answer dock clicks"

# Only these, so apps the user removed from the launcher stay removed.
# Terminal is refreshed so the user's copy gains X-Omarchy-Dock-Click=new.
mkdir -p ~/.local/share/applications
for app in Herdr omarchy-agent ChatGPT "Activity Monitor" omarchy-terminal; do
  cp "$OMARCHY_PATH/applications/$app.desktop" ~/.local/share/applications/
done
update-desktop-database ~/.local/share/applications
omarchy-theme-set-icons || true
