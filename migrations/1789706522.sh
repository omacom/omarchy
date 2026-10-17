echo "Register imv for AVIF, HEIF, HEIC, and JXL"

# Append the new types only when the MimeType line is still the stock one, so
# any other edits to the launcher (Exec, NoDisplay, a custom type list) are
# kept. --follow-symlinks edits a dotfiles-managed launcher in place instead of
# replacing the link with a regular file. GIO reads mimeinfo.cache, not the
# launcher itself, so it only lists imv for these types after the rebuild.
dest="$HOME/.local/share/applications/imv.desktop"
stock="MimeType=image/png;image/jpeg;image/jpg;image/gif;image/bmp;image/webp;image/tiff;image/x-xcf;image/x-portable-pixmap;image/x-xbitmap;"
registered="${stock}image/avif;image/heif;image/heic;image/jxl;"
if [[ -f $dest ]]; then
  if grep -qxF "$stock" "$dest"; then
    sed -i --follow-symlinks "s|^$stock\$|$registered|" "$dest"
  fi

  # Rebuild for the registered line too, so a retry after a failed rebuild
  # finishes the job instead of finding nothing left to append.
  if grep -qxF "$registered" "$dest"; then
    update-desktop-database "$HOME/.local/share/applications"
  fi
fi
