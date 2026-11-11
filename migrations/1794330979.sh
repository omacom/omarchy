echo "Replace Nautilus with Files as the file manager"

omarchy-pkg-add folio

# The packaged mimeapps.list now names Files, but a personal one in ~/.config
# still wins, so point any Nautilus association there at Files too.
user_mimeapps="$HOME/.config/mimeapps.list"
if [[ -f $user_mimeapps ]] && grep -q "org.gnome.Nautilus.desktop" "$user_mimeapps"; then
  sed --follow-symlinks -i 's/org\.gnome\.Nautilus\.desktop/folio.desktop/g' "$user_mimeapps"
fi

# A dock that still pins Nautilus pins Files instead.
shell_json="$HOME/.config/omarchy/shell.json"
if [[ -f $shell_json ]] && grep -q '"org.gnome.Nautilus"' "$shell_json"; then
  sed --follow-symlinks -i 's/"org\.gnome\.Nautilus"/"folio"/' "$shell_json"
fi

# Nautilus goes, with its extensions, its previewer and the LocalSearch
# indexer it brings along. nautilus-dropbox depends on it, so it goes too.
omarchy-pkg-drop nautilus nautilus-python nautilus-dropbox sushi
