echo "Ask RTKit directly for the speaker tuning's realtime priority"

# The tuning host asked for realtime through xdg-desktop-portal. A portal started
# before rtkit was installed reports a realtime budget of zero; module-rt applies
# it as a hard RLIMIT_RTTIME of 0, RTKit still makes the data thread realtime, and
# the kernel kills the host as soon as audio plays. The host config is only copied
# by `omarchy-audio-tuning on`, so an installed tuning keeps the old one until
# replaced here.
#
# Only Omarchy's own copy with the old setting is replaced. A community
# calibrator can host its graph under the same file name, and a tuning graph is
# never touched: `omarchy-audio-tuning on` would overwrite one it did not write.
host_config="${XDG_CONFIG_HOME:-$HOME/.config}/pipewire/omarchy-speaker-tuning.conf"
host_source="$OMARCHY_PATH/default/audio/filter-chain-host.conf"

if [[ -f $host_config && ! -L $host_config ]] &&
  grep -qx '# Host config for the Omarchy speaker tuning.' "$host_config" &&
  grep -q 'args = { }' "$host_config"; then
  install -Dm644 "$host_source" "$host_config"
  # A restart ends playback for a moment, so only a running host is restarted.
  systemctl --user try-restart omarchy-speaker-tuning.service >/dev/null 2>&1 || true
fi
