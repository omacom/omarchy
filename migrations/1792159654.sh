echo "Show the lock screen why a password was refused"

# The lock screen's PAM stack ran pam_faillock's preauth check silently, so a
# locked account (ten failures within the window, two minutes to unlock) made
# the lock screen refuse the right password with only "Authentication failed".
# omarchy-apply-lock now writes the stack without `silent` and the shell
# relays pam_faillock's own notice. Rewrite an existing stack once.
pam_file="${OMARCHY_LOCK_PAM_FILE:-/etc/pam.d/omarchy-lock-password}"
if ! grep -q 'pam_faillock.so preauth silent' "$pam_file" 2>/dev/null; then
  exit 0
fi

if ! omarchy-apply-lock; then
  echo "Administrator privileges are required to rewrite the lock screen's PAM stack. Run omarchy-migrate again from a terminal." >&2
  exit 1
fi
