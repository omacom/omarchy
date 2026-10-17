echo "Install Freebuff coding agent mise wrapper"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]] && omarchy-cmd-missing freebuff; then
  omarchy-mise-install npm:freebuff freebuff
fi
