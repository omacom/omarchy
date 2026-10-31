echo "Reload existing fingerprint resume configuration installed through protected directories"

# The earlier migration could install the drop-in with sudo, then miss its
# unprivileged -f check and finish without reloading systemd. Do not replay
# setup: an owner may since have removed the hook or changed their policy.
"$OMARCHY_PATH/bin/omarchy-apply-fprintd-resume" --reload-only
