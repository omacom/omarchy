echo "Install Phantombot coding agent mise wrapper"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]] && omarchy-cmd-missing phantombot; then
  omarchy-mise-install github:phantomyard/phantombot phantombot
fi
