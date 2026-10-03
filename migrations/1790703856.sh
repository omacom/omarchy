echo "Link Helix installed outside Omarchy to the current theme"

# Existing installations miss the link when Helix came from another installer.
helix_theme_link="$HOME/.config/helix/themes/omarchy.toml"
helix_theme="$HOME/.local/state/omarchy/current/theme/helix.toml"
if omarchy-cmd-present helix && [[ -f $helix_theme && ! -e $helix_theme_link && ! -L $helix_theme_link ]]; then
  mkdir -p "${helix_theme_link%/*}"
  ln -s "$helix_theme" "$helix_theme_link"
fi
