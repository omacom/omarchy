# The fingerprint overlay turns fingerprint login on through pkexec and
# omarchy-fingerprint-setup-helper; this polkit action gives that one
# admin prompt, remembered for a few minutes, instead of a terminal.
install -D -m 644 "$OMARCHY_PATH/default/polkit/org.omarchy.fingerprint.policy" \
  /usr/share/polkit-1/actions/org.omarchy.fingerprint.policy
