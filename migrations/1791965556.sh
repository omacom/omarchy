echo "Install Kilo coding agent mise wrapper"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]] && omarchy-cmd-missing kilo; then
  omarchy-mise-install npm:@kilocode/cli kilo
fi
