echo "Let browsers, Disks and Document Viewer use their own maximize button on floating workspaces"

# Only GNOME's default layout is replaced; a layout the user chose stays. Apps
# read it when they start, so they pick it up on their next launch.
if [[ $(gsettings get org.gnome.desktop.wm.preferences button-layout) == "'appmenu:close'" ]]; then
  gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:maximize,close"
fi
