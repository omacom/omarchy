echo "Install Command Code via mise wrapper"

# An npm -g install of command-code already puts commandcode on PATH, so an
# existing command is the user's and stays.
if omarchy-cmd-missing commandcode && [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  omarchy-mise-install npm:command-code commandcode
fi
