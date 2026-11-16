echo "Install Checkmate, the 3D chess game"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  omarchy-pkg-add checkmate
fi
