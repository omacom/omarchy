echo "Install Fantasi, the image maker"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  omarchy-pkg-add fantasi
fi
