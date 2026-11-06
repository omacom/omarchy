echo "Install titlebars for floating workspaces"

# Floating workspaces work without titlebars, so a Hyprland the plugin cannot
# load into skips it rather than stopping every migration after this one.
omarchy-pkg-add-hyprland-plugin omarchy-hyprland-titlebars
