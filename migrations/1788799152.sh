echo "Reuse one Alacritty process for new windows"

dest="$HOME/.local/share/applications/Alacritty.desktop"
if [[ -f $dest ]]; then
  cp "$OMARCHY_PATH/default/alacritty/Alacritty.desktop" "$dest"
fi
