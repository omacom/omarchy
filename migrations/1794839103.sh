echo "Install Cards, the Klondike solitaire game"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  omarchy-pkg-add cards
fi
