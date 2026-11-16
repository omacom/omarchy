echo "Use Files for other apps' Open and Save dialogs"

portal_config="${XDG_CONFIG_HOME:-$HOME/.config}/xdg-desktop-portal/hyprland-portals.conf"

# Only the portal config Omarchy installs, and only where no file chooser has
# been picked in it: a user's own portals.conf or choice stays as it is.
if [[ ! -f $portal_config ]]; then
  echo "No Omarchy portal config, skipping..."
  exit 0
fi
if grep -q '^org\.freedesktop\.impl\.portal\.FileChooser=' "$portal_config"; then
  echo "File chooser already configured, skipping..."
  exit 0
fi
if ! grep -qx '\[preferred\]' "$portal_config"; then
  echo "Portal config has no [preferred] section, skipping..."
  exit 0
fi

# Files first, GTK where Files doesn't provide the chooser yet.
sed --follow-symlinks -i '/^\[preferred\]$/a org.freedesktop.impl.portal.FileChooser=folio;gtk' "$portal_config"

# Activate it immediately in a live desktop
if systemctl --user is-active --quiet xdg-desktop-portal.service 2>/dev/null; then
  if ! systemctl --user restart xdg-desktop-portal.service; then
    echo "Failed to restart xdg-desktop-portal" >&2
  fi
fi
