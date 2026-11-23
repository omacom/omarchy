# Install hardware packages queued by pure-package hardware leaves.
if [[ -n ${OMARCHY_PKG_QUEUE_FILE:-} && -s $OMARCHY_PKG_QUEUE_FILE ]]; then
  OMARCHY_PKG_DEFER=0 omarchy-pkg-add
fi
