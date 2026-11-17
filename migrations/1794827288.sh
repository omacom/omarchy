echo "Install Checkmate, the 3D chess game"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  omarchy-pkg-add checkmate
fi

# Drawing the icon set puts its themed icon in the launcher right away, where
# it would otherwise wait for the next theme switch.
omarchy-theme-set-icons || true
