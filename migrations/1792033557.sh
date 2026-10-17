echo "Install MiniMax Code coding agent mise wrapper"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]] && omarchy-cmd-missing mcode; then
  omarchy-mise-install "npm:@minimax-ai/code[allow_builds=better-sqlite3]" mcode
fi
