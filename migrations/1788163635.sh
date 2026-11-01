echo "Remove legacy temporary passwordless sudo grants"

# Migration queues are per-user; the privileged repair is once per machine.
# The helper beside this migration: the package's /usr/bin copy on an install,
# and under a dev link the checkout's, which may be newer than the package.
helper="$OMARCHY_PATH/bin/omarchy-sudo-passwordless"
if ! "$helper" __migration-complete; then
  sudo "$helper" __migrate
fi
