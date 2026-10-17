echo "Install Mistral Vibe coding agent mise wrapper"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]] && omarchy-cmd-missing vibe; then
  omarchy-mise-install "github:mistralai/mistral-vibe[matching=vibe-linux]" vibe
fi
