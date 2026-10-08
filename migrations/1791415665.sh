echo "Install Goose via mise wrapper"

# Goose's own installer writes ~/.local/bin/goose, so an existing command is
# the user's and stays.
if omarchy-cmd-missing goose && [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  omarchy-mise-install "github:aaif-goose/goose[matching=unknown-linux-gnu.tar]" goose
fi
