echo "Use GTK for other apps' Open and Save dialogs"

portal_config="${XDG_CONFIG_HOME:-$HOME/.config}/xdg-desktop-portal/hyprland-portals.conf"

# Only undo the Files choice migration 1794775358 made: a user's own file
# chooser choice stays as it is.
if [[ ! -f $portal_config ]]; then
  echo "No Omarchy portal config, skipping..."
  exit 0
fi
if ! grep -qx 'org\.freedesktop\.impl\.portal\.FileChooser=folio;gtk' "$portal_config"; then
  echo "File chooser not set to Files, skipping..."
  exit 0
fi

# Files' chooser does not answer Cancel, so the GTK chooser answers again.
sed --follow-symlinks -i '/^org\.freedesktop\.impl\.portal\.FileChooser=folio;gtk$/d' "$portal_config"

# Activate it immediately in a live desktop
if systemctl --user is-active --quiet xdg-desktop-portal.service 2>/dev/null; then
  if ! systemctl --user restart xdg-desktop-portal.service; then
    echo "Failed to restart xdg-desktop-portal" >&2
  fi
fi
