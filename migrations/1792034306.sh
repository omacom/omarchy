echo "Install Command Code coding agent mise wrapper"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]] && omarchy-cmd-missing commandcode; then
  omarchy-mise-install npm:command-code commandcode
fi
