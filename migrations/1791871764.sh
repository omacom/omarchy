echo "Install opper (Opper CLI) via mise wrapper"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  omarchy-mise-install github:opper-ai/cli opper
fi
