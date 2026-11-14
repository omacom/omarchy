echo "Revoke existing passwordless sudo grants before switching to UID-based authorization"

# Migration queues are per-user; revoke both grant types once per machine.
helper="$OMARCHY_PATH/bin/omarchy-sudo-passwordless"
if ! "$helper" __migration-complete 1794660024; then
  sudo "$helper" __migrate 1794660024
  echo "Passwordless sudo grants have been revoked. Re-enable access through Setup > Security > Passwordless Sudo if needed."
fi
