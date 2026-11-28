echo "Launch cliamp from the app menu with its own window class"

if omarchy-cmd-present cliamp; then
  mkdir -p ~/.local/share/applications
  cp "$OMARCHY_PATH/applications/cliamp.desktop" ~/.local/share/applications/
  update-desktop-database ~/.local/share/applications
fi
