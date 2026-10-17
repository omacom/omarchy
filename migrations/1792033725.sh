echo "Install Goose coding agent mise wrapper"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]] && omarchy-cmd-missing goose; then
  omarchy-mise-install aqua:aaif-goose/goose goose
fi
