echo "Refresh the Basecamp CLI lazy tool"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  mise reshim --system
fi
