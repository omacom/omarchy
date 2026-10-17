echo "Install DeepSeek Harness coding agent mise wrapper"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]] && omarchy-cmd-missing dsh; then
  omarchy-mise-install npm:@deepseek-ai/dsh@0.2.0-rc.2 dsh
fi
