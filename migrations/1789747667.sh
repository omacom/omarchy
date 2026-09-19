echo "Install rtkit so PipeWire gets realtime priority"

# PipeWire requests realtime scheduling via RealtimeKit at startup, but rtkit
# is not a dependency of Arch's pipewire packages and the rlimits fallback is
# not configured either (see https://github.com/omacom/omarchy/issues/9390).
# Without it, audio threads run at SCHED_OTHER nice 0 and produce xruns under
# sustained load.
omarchy-pkg-add rtkit

# rtkit only takes effect when PipeWire re-requests priority at startup.
# Restart the audio units if they are running; harmless when idle or as root.
systemctl --user try-restart pipewire.service pipewire-pulse.service wireplumber.service 2>/dev/null || true
