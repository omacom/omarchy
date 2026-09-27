echo "Upgrade Omarchy-managed SSH hardening to a machine-validated key-only policy"

legacy_config=/etc/ssh/sshd_config.d/10-omarchy-hardening.conf
key_only_config=/etc/ssh/sshd_config.d/00-omarchy-key-only.conf
completion_marker=/var/lib/omarchy/migrations/1788163637

# The machine phase repairs the file old Omarchy wrote, validates a key-only
# file that was never certified, such as one an interrupted setup left
# behind, and makes key-only, or disables, a daemon old setup exposed without
# either. Otherwise, and once a validated conversion is recorded, later
# accounts finish here without privileges instead of prompting, or failing
# outright when they cannot use sudo.
sshd_may_be_exposed() {
  local enabled active
  enabled=$(/usr/bin/systemctl is-enabled sshd.service 2>/dev/null) || true
  active=$(/usr/bin/systemctl is-active sshd.service 2>/dev/null) || true
  # A runtime mask hides a persistent enablement that returns at boot.
  case "$enabled" in disabled | masked | not-found) ;; *) return 0 ;; esac
  case "$active" in inactive | failed) return 1 ;; *) return 0 ;; esac
}
if [[ ! -e $legacy_config && ! -L $legacy_config ]]; then
  if [[ ! -e $key_only_config && ! -L $key_only_config ]]; then
    sshd_may_be_exposed || exit 0
  elif [[ -f $completion_marker && ! -L $completion_marker && $(/usr/bin/stat -c %u -- "$completion_marker" 2>/dev/null) == 0 ]]; then
    exit 0
  fi
fi

# One root phase through sudo -N, which may use an authorization sudo already
# has but never creates or refreshes one, so the migration leaves nothing
# cached to revoke.
if ((EUID == 0)); then
  /usr/bin/omarchy-migrate-sshd-key-only
else
  /usr/bin/sudo -N -- /usr/bin/omarchy-migrate-sshd-key-only
fi
