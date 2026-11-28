echo "Install Flowtunes, endless music in the genre you pick"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  omarchy-pkg-add flowtunes
fi
