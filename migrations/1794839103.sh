echo "Install Cards, the Klondike solitaire game"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  omarchy-pkg-add cards
fi

# Drawing the icon set puts its themed icon in the launcher right away, where
# it would otherwise wait for the next theme switch.
omarchy-theme-set-icons || true
