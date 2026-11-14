echo "Make agent account selection apply to scripts and subprocesses"

# The settings package ships the mise wrapper declarations. Build the dispatch
# links for this user without installing or changing any agent version.
# Without mise there is nothing to dispatch to.
if omarchy-cmd-present mise; then
  mise reshim
fi
