echo "Replace the Disk Usage TUI with Disktree"

omarchy-pkg-add disktree-bin
omarchy-pkg-drop dua-cli

rm -f "$HOME/.local/share/applications/Disk Usage.desktop"
if [[ -d $HOME/.local/share/applications ]]; then
  update-desktop-database "$HOME/.local/share/applications"
fi
