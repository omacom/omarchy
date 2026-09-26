echo "Remove legacy temporary passwordless sudo grants"

# Migration queues are per-user; the privileged repair is once per machine.
# By name: secure_path resolves /usr/bin on an install and the checkout under a
# dev link, where the installed package may predate __migrate.
if ! omarchy-sudo-passwordless __migration-complete; then
  sudo omarchy-sudo-passwordless __migrate
fi
