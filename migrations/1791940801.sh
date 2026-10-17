echo "Install the Qwen Code agent stub"

if omarchy-cmd-missing qwen && [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  omarchy-mise-install npm:@qwen-code/qwen-code qwen
fi
