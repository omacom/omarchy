echo "Replace Evince with Papers as the document viewer"

omarchy-pkg-add papers

# The packaged mimeapps.list now names Papers, but a personal one in ~/.config
# still wins, so point any Evince association there at Papers too.
user_mimeapps="$HOME/.config/mimeapps.list"
if [[ -f $user_mimeapps ]] && grep -q "org.gnome.Evince.desktop" "$user_mimeapps"; then
  sed --follow-symlinks -i 's/org\.gnome\.Evince\.desktop/org.gnome.Papers.desktop/g' "$user_mimeapps"
fi

omarchy-pkg-drop evince
