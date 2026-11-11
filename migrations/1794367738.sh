echo "Add an optional Steam Big Picture launcher without replacing local entries"

launcher="$HOME/.local/share/applications/Steam Big Picture.desktop"
if [[ ! -e $launcher && ! -L $launcher ]]; then
  mkdir -p "$HOME/.local/share/applications"
  cp "$OMARCHY_PATH/applications/Steam Big Picture.desktop" "$launcher"
  update-desktop-database "$HOME/.local/share/applications"
fi

launcher="$HOME/.local/share/applications/Gaming Setup.desktop"
if [[ ! -e $launcher && ! -L $launcher ]]; then
  mkdir -p "$HOME/.local/share/applications"
  cp "$OMARCHY_PATH/applications/Gaming Setup.desktop" "$launcher"
  update-desktop-database "$HOME/.local/share/applications"
fi

launcher="$HOME/.local/share/applications/Desktop Mode.desktop"
if [[ ! -e $launcher && ! -L $launcher ]]; then
  mkdir -p "$HOME/.local/share/applications"
  cp "$OMARCHY_PATH/applications/Desktop Mode.desktop" "$launcher"
  update-desktop-database "$HOME/.local/share/applications"
fi
