echo "Install Amp coding agent mise wrapper"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]] && omarchy-cmd-missing amp; then
  omarchy-mise-install amp
fi
