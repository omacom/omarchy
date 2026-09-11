echo "Refresh the Muse Code lazy tool"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  mise reshim --system
fi
