echo "Use Papers as the only PDF viewer instead of Evince"

# Sushi (the Nautilus Space-bar previewer) already depends on Papers, so
# Evince left two identically named "Document Viewer" entries in the launcher.
# Evince is not required by anything else in the base install.
if omarchy-pkg-present evince; then
  omarchy-pkg-add papers
  omarchy-pkg-drop evince
fi

# Only repoint PDFs when the user is still on the old default.
mimeapps="${XDG_CONFIG_HOME:-$HOME/.config}/mimeapps.list"
if [[ -f $mimeapps ]] && grep -q '^application/pdf=org.gnome.Evince.desktop' "$mimeapps"; then
  sed -i --follow-symlinks 's/^application\/pdf=org.gnome.Evince.desktop/application\/pdf=org.gnome.Papers.desktop/' "$mimeapps"
fi