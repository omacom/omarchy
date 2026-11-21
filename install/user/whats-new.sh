# A new install starts out on its release, so that release's what's-new tour
# has nothing new to tell: mark it seen, and leave introducing Omarchy to the
# first-run welcome.
if release=$("$OMARCHY_PATH/bin/omarchy-update-whats-new-notes" --pending); then
  "$OMARCHY_PATH/bin/omarchy-done" mark "whats-new-$release"
fi
