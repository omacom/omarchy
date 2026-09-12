echo "Launch Kitty as a single instance"

if omarchy-cmd-present kitty; then
  mkdir -p "$HOME/.local/share/applications"
  cp "$OMARCHY_PATH/default/kitty/kitty.desktop" "$HOME/.local/share/applications/"
fi
