echo "Install Qwen Code coding agent mise wrapper"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]] && omarchy-cmd-missing qwen; then
  omarchy-mise-install npm:@qwen-code/qwen-code qwen
fi
