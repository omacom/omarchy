echo "Install the polkit action for fingerprint setup"

# The Fingerprint overlay turns fingerprint login on through pkexec; without
# this action pkexec has nothing to authorise. Idempotent across users.
if [[ ! -f /usr/share/polkit-1/actions/org.omarchy.fingerprint.policy ]]; then
  sudo install -D -m 644 "$OMARCHY_PATH/default/polkit/org.omarchy.fingerprint.policy" \
    /usr/share/polkit-1/actions/org.omarchy.fingerprint.policy
fi
