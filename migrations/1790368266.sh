echo "Install disktree, the disk space treemap"

# A preinstall, so it stays out for anyone who removed the preinstalls.
if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  omarchy-pkg-add disktree-bin
fi
