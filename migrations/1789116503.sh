echo "Open the whole folder in the image viewer, not just the clicked file"

# imv.desktop used to run `imv %F`. A file manager passes only the file that was
# clicked, so imv got a one-image playlist and next/prev (including the arrow
# keys) had nothing to move to. `imv-dir`, shipped with the imv package, opens
# the containing directory and starts on the clicked file, and passes a
# multi-file selection straight through. Refresh just that file.
dest="$HOME/.local/share/applications/imv.desktop"
if [[ -f $dest ]]; then
  cp "$OMARCHY_PATH/applications/imv.desktop" "$dest"
fi
