echo "Update the managed fingerprint resume hook"

hook=/usr/lib/systemd/system-sleep/fprintd-resume
[[ -f $hook && -x $hook && ! -L $hook ]] || exit 0

# Only replace the previous shipped hook. Keep administrator edits and
# setups that opted out of the automatic restart.
installed_hash=$(sha256sum "$hook")
if [[ ${installed_hash%% *} == "97b33e1ef96c6f173482d24131d68f3e6d2cd3b0233e64f01a551d3f553e8bb6" ]]; then
  sudo install -m755 "$OMARCHY_PATH/default/systemd/system-sleep/fprintd-resume" "$hook"
fi
