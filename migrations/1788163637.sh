echo "Upgrade Omarchy-managed SSH hardening to a machine-validated key-only policy"

if ((EUID == 0)); then
  /usr/bin/omarchy-migrate-sshd-key-only
else
  /usr/bin/sudo -k
  cleanup_ssh_migration_sudo() {
    local status=$?
    trap - EXIT HUP INT TERM
    /usr/bin/sudo -k >/dev/null 2>&1 || status=1
    exit "$status"
  }
  trap cleanup_ssh_migration_sudo EXIT
  trap 'exit 129' HUP
  trap 'exit 130' INT
  trap 'exit 143' TERM
  /usr/bin/sudo -N -- /usr/bin/omarchy-migrate-sshd-key-only
  /usr/bin/sudo -k
  trap - EXIT HUP INT TERM
fi
