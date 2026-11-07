echo "Hide the close button that apps drawing their own titlebar add under Hyprland"

# Electron apps with a titlebar overlay (T3 Code) and GTK header-bar apps take a
# lone close button from the GNOME button layout. Tiled windows have no other
# window buttons, so it reads like an in-app "close panel" button and quits the
# app; floating titlebars already bring their own (default/hypr/workspace-modes.lua).
# Leave a layout the user picked alone; only replace GNOME's stock default.
if [[ $(gsettings get org.gnome.desktop.wm.preferences button-layout) == "'appmenu:close'" ]]; then
  gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:"
fi
