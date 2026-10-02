echo "Install Hype, the Markdown presentation app"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  omarchy-pkg-add hype
fi
