echo "Install Signed, the PDF signing app"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  omarchy-pkg-add signed
fi
