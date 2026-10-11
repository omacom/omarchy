echo "Refresh the cf (Cloudflare CLI) lazy tool"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  mise reshim --system
fi
