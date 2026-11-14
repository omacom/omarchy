echo "Draw the default apps' icons as an icon set in the current theme's colors"

# App icons are now an icon set, picked with `omarchy icons set` apart from the
# theme, and the default set covers the other apps of a fresh install: Image
# Viewer, Media Player, Disks, Document Viewer and the rest.

# Icon templates of the user's own moved from ~/.config/omarchy/themed/icons to
# the set they redraw.
old_templates="$HOME/.config/omarchy/themed/icons"
if [[ -d $old_templates ]]; then
  mkdir -p "$HOME/.config/omarchy/icons/papercraft"
  find "$old_templates" -maxdepth 1 -name '*.svg.tpl' -exec mv -n -t "$HOME/.config/omarchy/icons/papercraft" {} +
  rmdir "$old_templates" 2>/dev/null || true
fi

# Drawing the set here links the new icons in right away, where they would
# otherwise wait for the next theme switch.
omarchy-theme-set-icons || true
