echo "Add Game Vibes, Omarchy's games, to the app launcher"

# New installs get the launcher with the other default ones; existing ones
# get it here. One already there, from opening Game Vibes, stays.
launcher="$HOME/.local/share/applications/Game Vibes.desktop"
if [[ ! -e $launcher ]]; then
  mkdir -p "${launcher%/*}"
  cp "$OMARCHY_PATH/applications/Game Vibes.desktop" "$launcher"
fi

# Drawing the icon set puts its themed icon in the launcher right away, where
# it would otherwise wait for the next theme switch.
omarchy-theme-set-icons || true
