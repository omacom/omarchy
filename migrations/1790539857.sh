echo "Install Monologue, the webcam recorder"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  omarchy-pkg-add monologue
fi
