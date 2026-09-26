echo "Disable SSH password authentication, or sshd itself when no key is authorized"

# Superseded by 1788163637. Its machine phase does this for every account at
# once, under the lock setup holds: an exposed daemon, with or without the
# file this migration once wrote, is made key-only when an account has a usable
# key and disabled otherwise. Doing it here, outside that lock, could undo a
# setup another account is running at the same time.
