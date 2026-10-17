echo "Install the DeepSeek Harness agent stub"

if omarchy-cmd-missing dsh && [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  omarchy-mise-install npm:@deepseek-ai/dsh@0.2.0-rc.2 dsh
fi
