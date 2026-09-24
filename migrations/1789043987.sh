echo "Install kilo via mise wrapper"

if omarchy-cmd-missing kilo && [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  omarchy-mise-install npm:@kilocode/cli kilo
fi
