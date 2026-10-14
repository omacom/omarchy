echo "Install Kimi coding agent mise wrapper"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]] && omarchy-cmd-missing kimi; then
  omarchy-mise-install npm:@moonshot-ai/kimi-code kimi
fi
