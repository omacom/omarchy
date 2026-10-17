echo "Install ZeroClaw coding agent mise wrapper"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]] && omarchy-cmd-missing zeroclaw; then
  omarchy-mise-install github:zeroclaw-labs/zeroclaw zeroclaw
fi
