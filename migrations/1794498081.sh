echo "Give Chromium-based browsers their own maximize button on floating workspaces"

# Browsers read the button layout when they start, so they pick it up on their next launch.
gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:maximize,close"
