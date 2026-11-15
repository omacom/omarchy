echo "Let Image Viewer navigate images in the same directory"

desktop_file="$HOME/.local/share/applications/imv.desktop"
if [[ -f $desktop_file ]]; then
  sed -i --follow-symlinks 's/^Exec=imv %F$/Exec=imv-dir %F/' "$desktop_file"
fi
